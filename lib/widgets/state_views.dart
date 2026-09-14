import 'package:flutter/material.dart';

/// Indicador de carregamento centralizado, usado em todas as telas que
/// buscam dados na API.
class CarregandoView extends StatelessWidget {
  const CarregandoView({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensagem != null) ...[
            const SizedBox(height: 16),
            Text(mensagem!, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Estado de erro com botão de "tentar novamente" — usado sempre que uma
/// chamada à API do Círio falha.
class ErroView extends StatelessWidget {
  const ErroView({super.key, required this.mensagem, this.aoTentarNovamente});

  final String mensagem;
  final VoidCallback? aoTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            if (aoTentarNovamente != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: aoTentarNovamente,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VazioView extends StatelessWidget {
  const VazioView({super.key, required this.mensagem, this.icone = Icons.inbox});

  final String mensagem;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
