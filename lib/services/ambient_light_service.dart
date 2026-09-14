import 'dart:async';
import 'dart:io';
import 'dart:ui' show Brightness;

import 'package:flutter/scheduler.dart';
import 'package:light_sensor/light_sensor.dart';

/// Nível de iluminação do ambiente, já traduzido para uma decisão de tema.
enum NivelDeLuz { claro, escuro }

/// Adapta a interface conforme a luminosidade do ambiente.
///
/// Em aparelhos Android com sensor de luz disponível, usamos a leitura em
/// lux do próprio sensor de luminosidade (via `light_sensor`) — abaixo de
/// [limiarLux] consideramos o ambiente escuro e ativamos o tema escuro.
///
/// Em plataformas sem esse sensor (iOS, web, desktop), não há uma API de
/// luz ambiente exposta ao app; nesse caso caímos de volta para o brilho
/// definido no sistema operacional, para que a interface ainda se adapte
/// (ainda que de forma indireta) às condições de uso.
class AmbientLightService {
  AmbientLightService({this.limiarLux = 15});

  final int limiarLux;

  StreamController<NivelDeLuz>? _controller;
  StreamSubscription<int>? _luxSubscription;
  bool _usandoFallbackDeSistema = false;

  Stream<NivelDeLuz> get streamDeNivel {
    _controller ??= StreamController<NivelDeLuz>.broadcast(
      onListen: _iniciar,
      onCancel: _parar,
    );
    return _controller!.stream;
  }

  Future<void> _iniciar() async {
    if (Platform.isAndroid) {
      try {
        final possuiSensor = await LightSensor.hasSensor();
        if (possuiSensor) {
          _luxSubscription = LightSensor.luxStream().listen((lux) {
            _controller?.add(
              lux < limiarLux ? NivelDeLuz.escuro : NivelDeLuz.claro,
            );
          });
          return;
        }
      } catch (_) {
        // Sem sensor de luz disponível — cai para o fallback abaixo.
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
