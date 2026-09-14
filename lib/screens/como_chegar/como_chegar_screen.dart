import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/utils/external_maps.dart';
import '../../models/rota_ate_inicio.dart';
import '../../services/cirio_api_service.dart';
import '../../services/location_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/como_chegar_controller.dart';
import '../../widgets/shake_to_recenter.dart';
import '../../widgets/state_views.dart';
import 'orientacao_screen.dart';

/// Mostra a posição do usuário, o trajeto até o ponto de início da
/// procissão (calculado pela API) e o percurso oficial da procissão, para
/// referência de quem ainda está se deslocando até lá.
class ComoChegarScreen extends StatelessWidget {
  const ComoChegarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ComoChegarController>(
      create: (context) => ComoChegarController(
        context.read<CirioApiService>(),
        context.read<LocationService>(),
      )..carregar(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Como Chegar ao Círio'),
          actions: [
            IconButton(
              tooltip: 'Modo orientação',
              icon: const Icon(Icons.explore),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrientacaoScreen()),
              ),
            ),
          ],
        ),
        body: const _ComoChegarBody(),
      ),
    );
  }
}

class _ComoChegarBody extends StatefulWidget {
  const _ComoChegarBody();

  @override
  State<_ComoChegarBody> createState() => _ComoChegarBodyState();
}

class _ComoChegarBodyState extends State<_ComoChegarBody> {
  final MapController _mapController = MapController();

  void _centralizarNoUsuario(LatLng? posicao) {
    if (posicao == null) return;
    _mapController.move(posicao, 15);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ComoChegarController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(
          mensagem: 'Obtendo sua localização e calculando a rota...',
        );
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem: controller.erro ?? 'Não foi possível calcular a rota.',
          aoTentarNovamente: controller.carregar,
        );
      case CarregamentoStatus.sucesso:
        final posicao = controller.posicaoUsuario!;
        final rotaAteInicio = controller.rotaAteInicio;
        final percursoOficial = controller.percursoOficial;

        return Column(
          children: [
            if (rotaAteInicio != null) _ResumoDaRota(rota: rotaAteInicio),
            Expanded(
              child: ShakeToRecenter(
                aoSacudir: () => _centralizarNoUsuario(controller.posicaoUsuario),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(initialCenter: posicao, initialZoom: 14),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cirio.app_cirio',
                    ),
                    PolylineLayer(
                      polylines: [
                        if (rotaAteInicio != null &&
                            rotaAteInicio.percurso.length > 1)
                          Polyline(
                            points: rotaAteInicio.percurso,
                            strokeWidth: 5,
                            color: Colors.blueAccent,
                          ),
                        if (percursoOficial != null &&
                            percursoOficial.percurso.length > 1)
                          Polyline(
                            points: percursoOficial.percurso,
                            strokeWidth: 5,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (rotaAteInicio?.destino != null)
                          Marker(
                            point: rotaAteInicio!.destino!.posicao,
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.flag,
                                color: Colors.green, size: 36),
                          ),
                        Marker(
                          point: posicao,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const _Legenda(),
          ],
        );
    }
  }
}

class _ResumoDaRota extends StatelessWidget {
  const _ResumoDaRota({required this.rota});

  final RotaAteInicio rota;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.directions_walk,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Até o início da procissão: ${rota.distanciaFormatada} '
              '(${rota.duracaoFormatada})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          if (rota.destino != null)
            IconButton(
              tooltip: 'Abrir rota em um app de mapas',
              icon: Icon(
                Icons.open_in_new,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () => abrirRotaNoAppDeMapas(rota.destino!.posicao),
            ),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ItemLegenda(cor: Colors.blueAccent, texto: 'Seu trajeto'),
          SizedBox(width: 16),
          _ItemLegenda(cor: Color(0xFF0D47A1), texto: 'Percurso oficial'),
        ],
      ),
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  const _ItemLegenda({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 6, color: cor),
        const SizedBox(width: 6),
        Text(texto, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
