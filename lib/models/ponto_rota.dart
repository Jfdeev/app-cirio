import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';

/// Um ponto (com ordem) usado para desenhar uma polyline no mapa — tanto
/// o trajeto oficial da procissão (`/mapa/cirio`) quanto a rota calculada
/// até o ponto de início (`/rota/ate-inicio`).
class PontoRota {
  const PontoRota({
    required this.latitude,
    required this.longitude,
    this.ordem,
  });

  factory PontoRota.fromJson(Map<String, dynamic> json) {
    return PontoRota(
      latitude: JsonUtils.asDouble(json['latitude']),
      longitude: JsonUtils.asDouble(json['longitude']),
      ordem: json['ordem'] is int
          ? json['ordem'] as int
          : int.tryParse(JsonUtils.asString(json['ordem'])),
    );
  }

  final double latitude;
  final double longitude;
  final int? ordem;

  LatLng get posicao => LatLng(latitude, longitude);
}

/// Converte uma lista de pontos crus (JSON) numa lista de [PontoRota]
/// ordenada pelo campo `ordem`, quando ele existir.
List<PontoRota> parsePontosRota(dynamic rawPontos) {
  if (rawPontos is! List) return const [];

  final pontos = rawPontos
      .whereType<Map>()
      .map((e) => PontoRota.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  final todosComOrdem = pontos.every((p) => p.ordem != null);
  if (todosComOrdem) {
    pontos.sort((a, b) => a.ordem!.compareTo(b.ordem!));
  }
  return pontos;
}
