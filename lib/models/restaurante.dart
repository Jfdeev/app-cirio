import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';

/// Restaurante de gastronomia paraense sugerido para quem acompanha o Círio.
class Restaurante {
  const Restaurante({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.endereco,
    required this.especialidades,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurante.fromJson(Map<String, dynamic> json) {
    return Restaurante(
      id: JsonUtils.asString(json['id']),
      nome: JsonUtils.asString(json['nome']),
      descricao: JsonUtils.asString(json['descricao']),
      endereco: JsonUtils.asString(json['endereco']),
      especialidades: JsonUtils.asStringList(json['especialidades']),
      latitude: JsonUtils.asDouble(json['latitude']),
      longitude: JsonUtils.asDouble(json['longitude']),
    );
  }

  final String id;
  final String nome;
  final String descricao;
  final String endereco;
  final List<String> especialidades;
  final double latitude;
  final double longitude;

  LatLng get posicao => LatLng(latitude, longitude);
}
