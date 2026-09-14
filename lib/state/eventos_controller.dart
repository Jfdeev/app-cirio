import 'package:flutter/foundation.dart';

import '../models/evento.dart';
import '../services/cirio_api_service.dart';
import 'carregamento_status.dart';

class EventosController extends ChangeNotifier {
  EventosController(this._api);

  final CirioApiService _api;

  CarregamentoStatus status = CarregamentoStatus.inicial;
  List<Evento> eventos = [];
  String? erro;

  Future<void> carregar() async {
    status = CarregamentoStatus.carregando;
    erro = null;
    notifyListeners();

    try {
      final lista = await _api.getEventos();
      lista.sort((a, b) => a.data.compareTo(b.data));
      eventos = lista;
      status = CarregamentoStatus.sucesso;
    } catch (e) {
      erro = e.toString();
      status = CarregamentoStatus.erro;
    }
    notifyListeners();
  }
}
