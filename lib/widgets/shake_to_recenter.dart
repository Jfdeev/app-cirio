import 'package:flutter/material.dart';

import '../services/shake_detector.dart';

/// Envolve uma tela de mapa e passa a escutar o acelerômetro: assim que o
/// usuário sacode o aparelho, [aoSacudir] é chamado (tipicamente para
/// centralizar o mapa na localização atual).
class ShakeToRecenter extends StatefulWidget {
  const ShakeToRecenter({
    super.key,
    required this.child,
    required this.aoSacudir,
    this.avisoAoSacudir = 'Centralizando no mapa...',
  });

  final Widget child;
  final VoidCallback aoSacudir;
  final String? avisoAoSacudir;

  @override
  State<ShakeToRecenter> createState() => _ShakeToRecenterState();
}

class _ShakeToRecenterState extends State<ShakeToRecenter> {
  final ShakeDetector _shakeDetector = ShakeDetector();

  @override
  void initState() {
    super.initState();
    _shakeDetector.eventos.listen((_) {
      widget.aoSacudir();
      final aviso = widget.avisoAoSacudir;
      if (aviso != null && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(aviso), duration: const Duration(seconds: 1)),
          );
      }
    });
    _shakeDetector.iniciar();
  }

  @override
  void dispose() {
    _shakeDetector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
