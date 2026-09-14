import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/cirio_rota.dart';
import '../models/local_referencia.dart';
import '../models/ponto_interesse.dart';
import '../services/cirio_api_service.dart';
import '../services/location_service.dart';
import 'carregamento_status.dart';

/// Estado da tela "Mapa do Círio": localização do usuário, ponto de
/// início e de chegada da procissão, pontos relevantes do trajeto e o
/// desenho completo do percurso — tudo obtido pela API.
class MapaCirioController extends ChangeNotifier {
  MapaCirioController(this._api, this._locationService);

  final CirioApiService _api;
  final LocationService _locationService;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  String? erro;

  CirioRota? rota;
  LocalReferencia? inicio;
  LocalReferencia? fim;
  List<PontoInteresse> pontosDeInteresse = [];

  LatLng? posicaoUsuario;
  StreamSubscription<LatLng>? _posicaoSubscription;

  Future<void> carregar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _api.getRotaDoCirio(),
        _api.getLocalDeInicio(),
        _api.getLocalDeChegada(),
        _api.getPontosDeInteresse(),
      ]);
      rota = resultados[0] as CirioRota;
      inicio = resultados[1] as LocalReferencia;
      fim = resultados[2] as LocalReferencia;
      pontosDeInteresse = resultados[3] as List<PontoInteresse>;
      status = CarregamentoStatus.sucesso;
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();

    _iniciarRastreioDeLocalizacao();
  }

  Future<void> _iniciarRastreioDeLocalizacao() async {
    try {
      await _locationService.ensurePermissao();
      posicaoUsuario = await _locationService.getPosicaoAtual();
      notifyListeners();
      _posicaoSubscription ??=
          _locationService.streamDePosicao.listen((posicao) {
        posicaoUsuario = posicao;
        notifyListeners();
      });
    } catch (_) {
      // Sem localização o mapa ainda funciona, só não centraliza o usuário.
    }
  }

  @override
  void dispose() {
    _posicaoSubscription?.cancel();
    super.dispose();
  }
}
