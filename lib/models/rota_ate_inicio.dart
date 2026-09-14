import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';
import 'local_referencia.dart';
import 'ponto_rota.dart';

/// Rota calculada pela API entre a posição atual do usuário e o ponto de
/// início da procissão — retornada pelo endpoint `/rota/ate-inicio`.
class RotaAteInicio {
  const RotaAteInicio({
    required this.origem,
    required this.destino,
    required this.distanciaMetros,
    required this.duracaoSegundos,
    required this.pontos,
  });

  factory RotaAteInicio.fromJson(Map<String, dynamic> json) {
    return RotaAteInicio(
      origem: json['origem'] is Map
          ? LocalReferencia.fromJson(Map<String, dynamic>.from(json['origem']))
          : null,
      destino: json['destino'] is Map
          ? LocalReferencia.fromJson(
              Map<String, dynamic>.from(json['destino']))
          : null,
      distanciaMetros: JsonUtils.asDoubleOrNull(json['distancia_metros']),
      duracaoSegundos: JsonUtils.asDoubleOrNull(json['duracao_segundos']),
      pontos: parsePontosRota(json['pontos']),
    );
  }

  final LocalReferencia? origem;
  final LocalReferencia? destino;
  final double? distanciaMetros;
  final double? duracaoSegundos;
  final List<PontoRota> pontos;

  List<LatLng> get percurso => pontos.map((p) => p.posicao).toList();

  String get distanciaFormatada {
    final metros = distanciaMetros;
    if (metros == null) return '--';
    if (metros >= 1000) return '${(metros / 1000).toStringAsFixed(1)} km';
    return '${metros.toStringAsFixed(0)} m';
  }

  String get duracaoFormatada {
    final segundos = duracaoSegundos;
    if (segundos == null) return '--';
    final minutos = (segundos / 60).round();
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final resto = minutos % 60;
    return '${horas}h${resto.toString().padLeft(2, '0')}';
  }
}
