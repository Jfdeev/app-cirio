import 'package:flutter/material.dart';

import '../../widgets/home_menu_button.dart';
import '../agenda/agenda_screen.dart';
import '../como_chegar/como_chegar_screen.dart';
import '../como_chegar/orientacao_screen.dart';
import '../gastronomia/gastronomia_screen.dart';
import '../mapa_cirio/mapa_cirio_screen.dart';
import '../noticias/noticias_screen.dart';

/// Tela inicial do app: dá acesso a todas as funcionalidades principais.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Círio de Nazaré'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _Cabecalho(),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  HomeMenuButton(
                    icone: Icons.newspaper,
                    titulo: 'Notícias',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NoticiasScreen()),
                    ),
                  ),
                  HomeMenuButton(
                    icone: Icons.event,
                    titulo: 'Agenda Cultural',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AgendaScreen()),
                    ),
                  ),
                  HomeMenuButton(
                    icone: Icons.restaurant_menu,
                    titulo: 'Gastronomia Paraense',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GastronomiaScreen()),
                    ),
                  ),
                  HomeMenuButton(
                    icone: Icons.map,
                    titulo: 'Mapa do Círio',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MapaCirioScreen()),
                    ),
                  ),
                  HomeMenuButton(
                    icone: Icons.directions,
                    titulo: 'Como Chegar',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ComoChegarScreen()),
                    ),
                  ),
                  HomeMenuButton(
                    icone: Icons.explore,
                    titulo: 'Modo Orientação',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrientacaoScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      color: scheme.primary,
      child: Text(
        'Programação, gastronomia e trajeto da procissão em Belém, tudo em um só lugar.',
        style: TextStyle(color: scheme.onPrimary),
      ),
    );
  }
}
