import 'package:latlong2/latlong.dart';

import '../core/utils/json_utils.dart';

/// Item da agenda cultural do Círio (missas, procissões, shows, etc).
class Evento {
  const Evento({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.data,
    required this.horario,
    required this.local,
    this.latitude,
    this.longitude,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: JsonUtils.asString(json['id']),
      nome: JsonUtils.asString(json['nome']),
      descricao: JsonUtils.asString(json['descricao']),
      data: JsonUtils.asString(json['data']),
      horario: JsonUtils.asString(json['horario']),
      local: JsonUtils.asString(json['local']),
      latitude: JsonUtils.asDoubleOrNull(json['latitude']),
      longitude: JsonUtils.asDoubleOrNull(json['longitude']),
    );
  }

  final String id;
  final String nome;
  final String descricao;
  final String data;
  final String horario;
  final String local;
  final double? latitude;
  final double? longitude;

  bool get temCoordenadas => latitude != null && longitude != null;

  LatLng? get posicao => temCoordenadas ? LatLng(latitude!, longitude!) : null;
}
