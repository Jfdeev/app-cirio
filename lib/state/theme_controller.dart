import 'dart:async';

import 'package:flutter/material.dart';

import '../services/ambient_light_service.dart';

/// Controla o [ThemeMode] do app de acordo com a luminosidade do ambiente,
/// captada pelo [AmbientLightService]. O usuário não precisa alternar o
/// tema manualmente: a interface se adapta sozinha.
class ThemeController extends ChangeNotifier {
  ThemeController(this._ambientLightService) {
    _subscription = _ambientLightService.streamDeNivel.listen((nivel) {
      final novoModo =
          nivel == NivelDeLuz.escuro ? ThemeMode.dark : ThemeMode.light;
      if (novoModo != themeMode) {
        themeMode = novoModo;
        notifyListeners();
      }
    });
  }

  final AmbientLightService _ambientLightService;
  late final StreamSubscription<NivelDeLuz> _subscription;

  ThemeMode themeMode = ThemeMode.light;

  @override
  void dispose() {
    _subscription.cancel();
    _ambientLightService.dispose();
    super.dispose();
  }
}
