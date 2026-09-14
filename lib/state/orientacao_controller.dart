import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/local_referencia.dart';
import '../services/cirio_api_service.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import 'carregamento_status.dart';

/// Estado do "modo de orientação": mantém, em tempo real, o ângulo que a
/// seta na tela deve apontar para levar o usuário até o ponto de início
/// da procissão — combinando a posição do usuário (GPS), a posição do
/// destino (API) e o rumo da bússola do aparelho.
class OrientacaoController extends ChangeNotifier {
  OrientacaoController(this._api, this._locationService, this._compassService);

  final CirioApiService _api;
  final LocationService _locationService;
  final CompassService _compassService;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  String? erro;

  LocalReferencia? destino;
  LatLng? posicaoUsuario;
  double? rumoDoAparelho;
  double? distanciaMetros;

  /// Ângulo (graus, 0-360) que a seta deve ter na tela: já descontado o
  /// rumo do aparelho, então `0` sempre significa "seta apontando para
  /// cima, na direção certa".
  double? get anguloDaSeta {
    final destinoAtual = destino;
    final posicaoAtual = posicaoUsuario;
    final rumoAtual = rumoDoAparelho;
    if (destinoAtual == null || posicaoAtual == null || rumoAtual == null) {
      return null;
    }
    final rumoAlvo = _locationService.calcularRumo(
      posicaoAtual,
      destinoAtual.posicao,
    );
    return (rumoAlvo - rumoAtual + 360) % 360;
  }

  StreamSubscription<LatLng>? _posicaoSubscription;
  StreamSubscription<double>? _rumoSubscription;

  bool get bussolaSuportada => _compassService.isSuportado;

  Future<void> iniciar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      destino = await _api.getLocalDeInicio();
      posicaoUsuario = await _locationService.getPosicaoAtual();
      _atualizarDistancia();
      status = CarregamentoStatus.sucesso;

      _posicaoSubscription ??=
          _locationService.streamDePosicao.listen((posicao) {
        posicaoUsuario = posicao;
        _atualizarDistancia();
        notifyListeners();
      });

      _rumoSubscription ??= _compassService.streamDeRumo.listen((rumo) {
        rumoDoAparelho = rumo;
        notifyListeners();
      });
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();
  }

  void _atualizarDistancia() {
    final destinoAtual = destino;
    final posicaoAtual = posicaoUsuario;
    if (destinoAtual == null || posicaoAtual == null) return;
    distanciaMetros = _locationService.calcularDistanciaMetros(
      posicaoAtual,
      destinoAtual.posicao,
    );
  }

  @override
  void dispose() {
    _posicaoSubscription?.cancel();
    _rumoSubscription?.cancel();
    super.dispose();
  }
}
