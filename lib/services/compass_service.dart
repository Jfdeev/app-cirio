import 'package:flutter_compass/flutter_compass.dart';

/// Expõe a bússola do aparelho (sensor de campo magnético) como uma stream
/// simples de graus (0-360, sentido horário, 0 = norte magnético).
///
/// Usado pelo modo de orientação para girar a seta continuamente conforme
/// o usuário gira o smartphone.
class CompassService {
  bool get isSuportado => FlutterCompass.events != null;

  Stream<double> get streamDeRumo {
    final events = FlutterCompass.events;
    if (events == null) return const Stream.empty();
    return events
        .where((event) => event.heading != null)
        .map((event) => (event.heading! + 360) % 360);
  }
}
