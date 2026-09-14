import 'package:flutter/foundation.dart';

import '../models/noticia.dart';
import '../services/cirio_api_service.dart';
import 'carregamento_status.dart';

class NoticiasController extends ChangeNotifier {
  NoticiasController(this._api);

  final CirioApiService _api;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  List<Noticia> noticias = [];
  String? erro;

  Future<void> carregar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      noticias = await _api.getNoticias();
      status = CarregamentoStatus.sucesso;
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();
  }
}
