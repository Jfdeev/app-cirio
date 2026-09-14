import 'dart:async';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Nível de iluminação do ambiente, já traduzido para uma decisão de tema.
enum NivelDeLuz { claro, escuro }

/// Adapta a interface conforme a luminosidade do ambiente.
///
/// Em Android, lemos o sensor de luz do próprio aparelho
/// (`Sensor.TYPE_LIGHT`) através de um `EventChannel` nativo implementado
/// em `MainActivity.kt` — abaixo de [limiarLux] consideramos o ambiente
/// escuro e ativamos o tema escuro. Optamos por esse canal nativo próprio
/// em vez de um pacote de terceiros porque as opções disponíveis no pub.dev
/// para esse sensor estão desatualizadas e incompatíveis com versões
/// recentes do Android Gradle Plugin.
///
/// Em plataformas sem esse sensor (iOS, web, desktop) ou em aparelhos
/// Android sem sensor de luz, caímos de volta para o brilho definido no
/// sistema operacional, para que a interface ainda se adapte (ainda que de
/// forma indireta) às condições de uso.
class AmbientLightService {
  AmbientLightService({this.limiarLux = 15});

  final int limiarLux;

  static const EventChannel _canalDoSensor =
      EventChannel('com.cirio.app_cirio/light_sensor');

  StreamController<NivelDeLuz>? _controller;
  StreamSubscription<dynamic>? _luxSubscription;
  bool _usandoFallbackDeSistema = false;

  Stream<NivelDeLuz> get streamDeNivel {
    _controller ??= StreamController<NivelDeLuz>.broadcast(
      onListen: _iniciar,
      onCancel: _parar,
    );
    return _controller!.stream;
  }

  void _iniciar() {
    if (Platform.isAndroid) {
      try {
        _luxSubscription = _canalDoSensor.receiveBroadcastStream().listen(
          (valor) {
            final lux = (valor as num).toDouble();
            _controller?.add(
              lux < limiarLux ? NivelDeLuz.escuro : NivelDeLuz.claro,
            );
          },
          onError: (_) => _usarFallbackDeSistema(),
          // Sem sensor de luz disponível no aparelho: o lado nativo encerra
          // o stream e caímos no fallback de brilho do sistema.
          onDone: _usarFallbackDeSistema,
          cancelOnError: true,
        );
        return;
      } catch (_) {
        // Segue para o fallback abaixo.
      }
    }
    _usarFallbackDeSistema();
  }

  void _usarFallbackDeSistema() {
    _usandoFallbackDeSistema = true;
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    void emitirBrilhoAtual() {
      _controller?.add(
        dispatcher.platformBrightness == Brightness.dark
            ? NivelDeLuz.escuro
            : NivelDeLuz.claro,
      );
    }

    emitirBrilhoAtual();
    dispatcher.onPlatformBrightnessChanged = emitirBrilhoAtual;
  }

  void _parar() {
    _luxSubscription?.cancel();
    _luxSubscription = null;
    if (_usandoFallbackDeSistema) {
      SchedulerBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
          null;
      _usandoFallbackDeSistema = false;
    }
  }

  void dispose() {
    _parar();
    _controller?.close();
    _controller = null;
  }
}
