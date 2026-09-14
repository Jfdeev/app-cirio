import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/cirio_api_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/eventos_controller.dart';
import '../../widgets/evento_card.dart';
import '../../widgets/state_views.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventosController>(
      create: (context) =>
          EventosController(context.read<CirioApiService>())..carregar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Agenda Cultural')),
        body: const _AgendaBody(),
      ),
    );
  }
}

class _AgendaBody extends StatelessWidget {
  const _AgendaBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventosController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(mensagem: 'Carregando a agenda cultural...');
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem: controller.erro ?? 'Não foi possível carregar a agenda.',
          aoTentarNovamente: controller.carregar,
        );
      case CarregamentoStatus.sucesso:
        if (controller.eventos.isEmpty) {
          return const VazioView(
            mensagem: 'Nenhum evento cadastrado no momento.',
            icone: Icons.event_busy,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.carregar,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.eventos.length,
            itemBuilder: (context, index) =>
                EventoCard(evento: controller.eventos[index]),
          ),
        );
    }
  }
}
