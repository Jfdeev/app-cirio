import 'package:flutter/foundation.dart';

import '../models/restaurante.dart';
import '../services/cirio_api_service.dart';
import 'carregamento_status.dart';

class RestaurantesController extends ChangeNotifier {
  RestaurantesController(this._api);

  final CirioApiService _api;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  List<Restaurante> restaurantes = [];
  String? erro;

  Future<void> carregar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      restaurantes = await _api.getRestaurantes();
      status = CarregamentoStatus.sucesso;
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();
  }
}
