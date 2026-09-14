import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';

/// Ponto relevante ao longo do trajeto da procissão (banheiro, posto de
/// saúde, ponto de apoio, referência turística, etc).
class PontoInteresse {
  const PontoInteresse({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.descricao,
    required this.latitude,
    required this.longitude,
  });

  factory PontoInteresse.fromJson(Map<String, dynamic> json) {
    return PontoInteresse(
      id: JsonUtils.asString(json['id']),
      nome: JsonUtils.asString(json['nome']),
      tipo: JsonUtils.asString(json['tipo']),
      descricao: JsonUtils.asString(json['descricao']),
      latitude: JsonUtils.asDouble(json['latitude']),
      longitude: JsonUtils.asDouble(json['longitude']),
    );
  }

  final String id;
  final String nome;
  final String tipo;
  final String descricao;
  final double latitude;
  final double longitude;

  LatLng get posicao => LatLng(latitude, longitude);
}
