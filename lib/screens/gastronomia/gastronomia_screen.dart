import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cirio_api_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/restaurantes_controller.dart';
import '../../widgets/restaurante_card.dart';
import '../../widgets/state_views.dart';
import 'restaurante_mapa_screen.dart';

class GastronomiaScreen extends StatelessWidget {
  const GastronomiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantesController>(
      create: (context) =>
          RestaurantesController(context.read<CirioApiService>())..carregar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gastronomia Paraense')),
        body: const _GastronomiaBody(),
      ),
    );
  }
}

class _GastronomiaBody extends StatelessWidget {
  const _GastronomiaBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RestaurantesController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(mensagem: 'Carregando restaurantes...');
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem:
              controller.erro ?? 'Não foi possível carregar os restaurantes.',
          aoTentarNovamente: controller.carregar,
        );
      case CarregamentoStatus.sucesso:
        if (controller.restaurantes.isEmpty) {
          return const VazioView(
            mensagem: 'Nenhum restaurante cadastrado no momento.',
            icone: Icons.no_meals_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.restaurantes.length,
            itemBuilder: (context, index) {
              final restaurante = controller.restaurantes[index];
              return RestauranteCard(
                restaurante: restaurante,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestauranteMapaScreen(restaurante: restaurante),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
