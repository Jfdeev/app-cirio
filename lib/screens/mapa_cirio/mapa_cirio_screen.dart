import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../services/cirio_api_service.dart';
import '../../services/location_service.dart';
import '../../state/carregamento_status.dart';
import '../../state/mapa_cirio_controller.dart';
import '../../widgets/shake_to_recenter.dart';
import '../../widgets/state_views.dart';

/// Mapa completo da procissão: posição do usuário, ponto de início, ponto
/// de chegada, pontos relevantes ao longo do percurso e o trajeto oficial
/// desenhado como uma polyline — tudo vindo da API.
class MapaCirioScreen extends StatelessWidget {
  const MapaCirioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapaCirioController>(
      create: (context) => MapaCirioController(
        context.read<CirioApiService>(),
        context.read<LocationService>(),
      )..carregar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Mapa do Círio')),
        body: const _MapaCirioBody(),
      ),
    );
  }
}

// Dica de uso: além de sacudir o aparelho, também é possível recentralizar
// o mapa segurando e arrastando manualmente — o gesto de sacudir só agiliza
// a volta para a localização atual (requisito de "centralização rápida").

class _MapaCirioBody extends StatefulWidget {
  const _MapaCirioBody();

  @override
  State<_MapaCirioBody> createState() => _MapaCirioBodyState();
}

class _MapaCirioBodyState extends State<_MapaCirioBody> {
  final MapController _mapController = MapController();

  void _centralizarNoUsuario(LatLng? posicao) {
    if (posicao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização atual ainda não disponível.')),
      );
      return;
    }
    _mapController.move(posicao, 15);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MapaCirioController>();

    switch (controller.status) {
      case CarregamentoStatus.inicial:
      case CarregamentoStatus.carregando:
        return const CarregandoView(mensagem: 'Carregando o mapa do Círio...');
      case CarregamentoStatus.erro:
        return ErroView(
          mensagem: controller.erro ?? 'Não foi possível carregar o mapa.',
          aoTentarNovamente: controller.carregar,
        );
      case CarregamentoStatus.sucesso:
        final rota = controller.rota;
        final centroInicial = rota?.inicio?.posicao ??
            (rota?.percurso.isNotEmpty == true ? rota!.percurso.first : const LatLng(-1.4558, -48.4902));

        return ShakeToRecenter(
          aoSacudir: () => _centralizarNoUsuario(controller.posicaoUsuario),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centroInicial,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cirio.app_cirio',
              ),
              if (rota != null && rota.percurso.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: rota.percurso,
                      strokeWidth: 5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (controller.inicio != null)
                    Marker(
                      point: controller.inicio!.posicao,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.flag, color: Colors.green, size: 36),
                    ),
                  if (controller.fim != null)
                    Marker(
                      point: controller.fim!.posicao,
                      width: 44,
                      height: 44,
                      child: const Icon(Icons.sports_score, color: Colors.red, size: 36),
                    ),
                  for (final ponto in controller.pontosDeInteresse)
                    Marker(
                      point: ponto.posicao,
                      width: 36,
                      height: 36,
                      child: Tooltip(
                        message: ponto.nome,
                        child: const Icon(Icons.info, color: Colors.orange, size: 28),
                      ),
                    ),
                  if (controller.posicaoUsuario != null)
                    Marker(
                      point: controller.posicaoUsuario!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
    }
  }
}
