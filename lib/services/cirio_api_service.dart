import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../core/network/api_exception.dart';
import '../models/cirio_rota.dart';
import '../models/evento.dart';
import '../models/local_referencia.dart';
import '../models/noticia.dart';
import '../models/ponto_interesse.dart';
import '../models/restaurante.dart';
import '../models/rota_ate_inicio.dart';

/// Camada única de acesso à API REST do Círio de Nazaré
/// (https://cirio-belem-api.onrender.com). Todas as telas do app obtêm
/// seus dados através deste serviço — nenhuma informação de notícia,
/// evento, restaurante, ponto de interesse ou trajeto é mantida "fixa"
/// no código do aplicativo.
class CirioApiService {
  CirioApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Noticia>> getNoticias() async {
    final json = await _getList(ApiConstants.noticias);
    return json.map(Noticia.fromJson).toList();
  }

  Future<Noticia> getNoticia(String id) async {
    final json = await _getObject(ApiConstants.noticia(id));
    return Noticia.fromJson(json);
  }

  Future<List<Evento>> getEventos() async {
    final json = await _getList(ApiConstants.eventos);
    return json.map(Evento.fromJson).toList();
  }

  Future<List<Restaurante>> getRestaurantes() async {
    final json = await _getList(ApiConstants.restaurantes);
    return json.map(Restaurante.fromJson).toList();
  }

  Future<List<PontoInteresse>> getPontosDeInteresse() async {
    final json = await _getList(ApiConstants.mapaPontos);
    return json.map(PontoInteresse.fromJson).toList();
  }

  Future<CirioRota> getRotaDoCirio() async {
    final json = await _getObject(ApiConstants.mapaCirio);
    return CirioRota.fromJson(json);
  }

  Future<LocalReferencia> getLocalDeInicio() async {
    final json = await _getObject(ApiConstants.mapaInicio);
    return LocalReferencia.fromJson(json);
  }

  Future<LocalReferencia> getLocalDeChegada() async {
    final json = await _getObject(ApiConstants.mapaFim);
    return LocalReferencia.fromJson(json);
  }

  /// Pede à API a rota entre a posição atual do usuário e o ponto de
  /// início da procissão.
  Future<RotaAteInicio> getRotaAteInicio({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.rotaAteInicio}')
        .replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });
    final json = await _getObjectFromUri(uri);
    return RotaAteInicio.fromJson(json);
  }

  // ---------------------------------------------------------------------
  // Helpers HTTP
  // ---------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final data = await _get(Uri.parse('${ApiConstants.baseUrl}$path'));
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    // Algumas APIs envolvem a lista num objeto, ex: { "resultados": [...] }.
    if (data is Map) {
      final possivelLista = data.values.whereType<List>().firstOrNull;
      if (possivelLista != null) {
        return possivelLista
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    throw ApiException('Resposta inesperada da API em $path.');
  }

  Future<Map<String, dynamic>> _getObject(String path) {
    return _getObjectFromUri(Uri.parse('${ApiConstants.baseUrl}$path'));
  }

  Future<Map<String, dynamic>> _getObjectFromUri(Uri uri) async {
    final data = await _get(uri);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ApiException('Resposta inesperada da API em ${uri.path}.');
  }

  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(ApiConstants.timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'A API respondeu com erro ${response.statusCode} em ${uri.path}.',
          statusCode: response.statusCode,
        );
      }
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on FormatException {
      throw ApiException('A API retornou um conteúdo inválido em ${uri.path}.');
    } catch (e) {
      throw ApiException(
        'Não foi possível conectar à API do Círio (${uri.path}). '
        'Verifique sua conexão e tente novamente.',
      );
    }
  }

  void dispose() => _client.close();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
