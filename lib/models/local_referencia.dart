import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';

/// Um local de referência simples (nome + coordenadas), usado para os
/// endpoints `/mapa/inicio` e `/mapa/fim`, e também para o `destino` do
/// endpoint `/rota/ate-inicio`.
class LocalReferencia {
  const LocalReferencia({
    required this.nome,
    required this.latitude,
    required this.longitude,
  });

  factory LocalReferencia.fromJson(Map<String, dynamic> json) {
    return LocalReferencia(
      nome: JsonUtils.asString(json['nome']),
      latitude: JsonUtils.asDouble(json['latitude']),
      longitude: JsonUtils.asDouble(json['longitude']),
    );
  }

  final String nome;
  final double latitude;
  final double longitude;

  LatLng get posicao => LatLng(latitude, longitude);
}
