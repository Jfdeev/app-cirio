import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

/// Detecta o gesto de "sacudir" o aparelho a partir do acelerômetro, para
/// permitir a centralização rápida do mapa na localização do usuário.
///
/// A cada leitura do acelerômetro calculamos a magnitude do vetor de
/// aceleração e subtraímos a gravidade (~9.8 m/s²); se o resultado
/// ultrapassar [limiar] algumas vezes seguidas dentro de uma janela curta,
/// consideramos que houve uma sacudida e emitimos um evento em [eventos],
/// respeitando um tempo mínimo ([intervaloMinimo]) entre disparos para
/// evitar múltiplos acionamentos seguidos.
class ShakeDetector {
  ShakeDetector({
    this.limiar = 18.0,
    this.contagemMinima = 2,
    this.janela = const Duration(milliseconds: 700),
    this.intervaloMinimo = const Duration(seconds: 1, milliseconds: 500),
  });

  final double limiar;
  final int contagemMinima;
  final Duration janela;
  final Duration intervaloMinimo;

  final StreamController<void> _controller = StreamController<void>.broadcast();
  StreamSubscription<AccelerometerEvent>? _subscription;

  DateTime? _primeiraOcorrenciaNaJanela;
  int _ocorrenciasNaJanela = 0;
  DateTime? _ultimoDisparo;

  Stream<void> get eventos => _controller.stream;

  void iniciar() {
    _subscription ??= accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onEvento);
  }

  void _onEvento(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    // Aceleração "pura" (sem a gravidade), em m/s².
    final aceleracao = (magnitude - 9.8).abs();
    if (aceleracao < limiar) return;

    final agora = DateTime.now();

    if (_primeiraOcorrenciaNaJanela == null ||
        agora.difference(_primeiraOcorrenciaNaJanela!) > janela) {
      _primeiraOcorrenciaNaJanela = agora;
      _ocorrenciasNaJanela = 1;
    } else {
      _ocorrenciasNaJanela++;
    }

    final passouIntervaloMinimo =
        _ultimoDisparo == null || agora.difference(_ultimoDisparo!) > intervaloMinimo;

    if (_ocorrenciasNaJanela >= contagemMinima && passouIntervaloMinimo) {
      _ultimoDisparo = agora;
      _ocorrenciasNaJanela = 0;
      _primeiraOcorrenciaNaJanela = null;
      _controller.add(null);
    }
  }

  void pausar() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    pausar();
    _controller.close();
  }
}
