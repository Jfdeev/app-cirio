import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/cirio_rota.dart';
import '../models/rota_ate_inicio.dart';
import '../services/cirio_api_service.dart';
import '../services/location_service.dart';
import 'carregamento_status.dart';

/// Estado da tela "Como chegar ao Círio": posição do usuário, trajeto até
/// o ponto de início da procissão (calculado pela API a partir da posição
/// atual) e o percurso oficial da procissão, para referência.
class ComoChegarController extends ChangeNotifier {
  ComoChegarController(this._api, this._locationService);

  final CirioApiService _api;
  final LocationService _locationService;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  String? erro;

  LatLng? posicaoUsuario;
  RotaAteInicio? rotaAteInicio;
  CirioRota? percursoOficial;

  StreamSubscription<LatLng>? _posicaoSubscription;

  Future<void> carregar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      final posicao = await _locationService.getPosicaoAtual();
      posicaoUsuario = posicao;

      final resultados = await Future.wait([
        _api.getRotaAteInicio(
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        ),
        _api.getRotaDoCirio(),
      ]);
      rotaAteInicio = resultados[0] as RotaAteInicio;
      percursoOficial = resultados[1] as CirioRota;
      status = CarregamentoStatus.sucesso;

      _posicaoSubscription ??=
          _locationService.streamDePosicao.listen((novaPosicao) {
        posicaoUsuario = novaPosicao;
        notifyListeners();
      });
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _posicaoSubscription?.cancel();
    super.dispose();
  }
}
