import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cirio_api_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/noticias_controller.dart';
import '../../widgets/noticia_card.dart';
import '../../widgets/state_views.dart';
import 'noticia_detalhe_screen.dart';

class NoticiasScreen extends StatelessWidget {
  const NoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NoticiasController>(
      create: (context) =>
          NoticiasController(context.read<CirioApiService>())..carregar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Notícias')),
        body: const _NoticiasBody(),
      ),
    );
  }
}

class _NoticiasBody extends StatelessWidget {
  const _NoticiasBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NoticiasController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(mensagem: 'Carregando notícias...');
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem: controller.erro ?? 'Não foi possível carregar as notícias.',
          aoTentarNovamente: controller.carregar,
        );
      case CarregamentoStatus.sucesso:
        if (controller.noticias.isEmpty) {
          return const VazioView(
            mensagem: 'Nenhuma notícia disponível no momento.',
            icone: Icons.newspaper,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.noticias.length,
            itemBuilder: (context, index) {
              final noticia = controller.noticias[index];
              return NoticiaCard(
                noticia: noticia,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoticiaDetalheScreen(noticia: noticia),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}
