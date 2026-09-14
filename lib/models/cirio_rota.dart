import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';
import 'local_referencia.dart';
import 'ponto_rota.dart';

/// Trajeto completo e oficial da procissão do Círio, com o ponto de
/// início, o ponto de chegada e a sequência de coordenadas do percurso —
/// retornado pelo endpoint `/mapa/cirio`.
class CirioRota {
  const CirioRota({
    required this.id,
    required this.nome,
    required this.data,
    required this.distanciaKm,
    required this.inicio,
    required this.fim,
    required this.pontos,
  });

  factory CirioRota.fromJson(Map<String, dynamic> json) {
    return CirioRota(
      id: JsonUtils.asString(json['id']),
      nome: JsonUtils.asString(json['nome']),
      data: JsonUtils.asString(json['data']),
      distanciaKm: JsonUtils.asDoubleOrNull(json['distancia_km']),
      inicio: json['inicio'] is Map
          ? LocalReferencia.fromJson(Map<String, dynamic>.from(json['inicio']))
          : null,
      fim: json['fim'] is Map
          ? LocalReferencia.fromJson(Map<String, dynamic>.from(json['fim']))
          : null,
      pontos: parsePontosRota(json['pontos']),
    );
  }

  final String id;
  final String nome;
  final String data;
  final double? distanciaKm;
  final LocalReferencia? inicio;
  final LocalReferencia? fim;
  final List<PontoRota> pontos;

  /// Coordenadas do percurso, prontas para alimentar uma `Polyline` do
  /// `flutter_map`.
  List<LatLng> get percurso => pontos.map((p) => p.posicao).toList();
}
