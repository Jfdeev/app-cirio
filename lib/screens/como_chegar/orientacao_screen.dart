import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cirio_api_service.dart';
import '../../services/compass_service.dart';
import '../../services/location_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/orientacao_controller.dart';
import '../../widgets/state_views.dart';

/// Modo de orientação: uma seta na tela aponta continuamente para o local
/// de início da procissão, recalculando o ângulo conforme o usuário se
/// desloca (GPS) e conforme gira o aparelho (bússola/magnetômetro).
class OrientacaoScreen extends StatelessWidget {
  const OrientacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrientacaoController>(
      create: (context) => OrientacaoController(
        context.read<CirioApiService>(),
        context.read<LocationService>(),
        context.read<CompassService>(),
      )..iniciar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Modo Orientação')),
        body: const _OrientacaoBody(),
      ),
    );
  }
}

class _OrientacaoBody extends StatelessWidget {
  const _OrientacaoBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<OrientacaoController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(mensagem: 'Preparando a bússola...');
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem: controller.erro ?? 'Não foi possível iniciar a orientação.',
          aoTentarNovamente: controller.iniciar,
        );
      case CarregamentoStatus.sucesso:
        if (!controller.bussolaSuportada) {
          return const VazioView(
            mensagem:
                'Este aparelho não possui bússola (magnetômetro) disponível, '
                'necessária para o modo de orientação.',
            icone: Icons.explore_off,
          );
        }

        final angulo = controller.anguloDaSeta;
        final distancia = controller.distanciaMetros;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Siga em direção a',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                controller.destino?.nome ?? 'ponto de início da procissão',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (angulo == null)
                const CarregandoView(mensagem: 'Aguardando sinal da bússola e do GPS...')
              else
                AnimatedRotation(
                  turns: angulo / 360,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.navigation,
                    size: 160,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              const SizedBox(height: 32),
              if (distancia != null)
                Text(
                  _formatarDistancia(distancia),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Gire o aparelho: a seta acompanha automaticamente a '
                  'direção do ponto de início da procissão.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
    }
  }

  String _formatarDistancia(double metros) {
    if (metros >= 1000) {
      return '${(metros / 1000).toStringAsFixed(1)} km restantes';
    }
    return '${metros.toStringAsFixed(0)} m restantes';
  }
}

// Ângulo da seta = rumo(usuário -> destino) - rumo do aparelho (bússola),
// normalizado para 0-360°. Ver OrientacaoController.anguloDaSeta.
