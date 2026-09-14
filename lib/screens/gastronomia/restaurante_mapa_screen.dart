import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../models/restaurante.dart';
import '../../widgets/shake_to_recenter.dart';

/// Mostra a localização de um único restaurante no mapa, junto com suas
/// informações (endereço, descrição e especialidades).
class RestauranteMapaScreen extends StatefulWidget {
  const RestauranteMapaScreen({super.key, required this.restaurante});

  final Restaurante restaurante;

  @override
  State<RestauranteMapaScreen> createState() => _RestauranteMapaScreenState();
}

class _RestauranteMapaScreenState extends State<RestauranteMapaScreen> {
  final MapController _mapController = MapController();
  static const double _zoomPadrao = 16;

  void _centralizar() {
    _mapController.move(widget.restaurante.posicao, _zoomPadrao);
  }

  @override
  Widget build(BuildContext context) {
    final restaurante = widget.restaurante;
    return Scaffold(
      appBar: AppBar(title: Text(restaurante.nome)),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: ShakeToRecenter(
              aoSacudir: _centralizar,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: restaurante.posicao,
                  initialZoom: _zoomPadrao,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.cirio.app_cirio',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: restaurante.posicao,
                        width: 48,
                        height: 48,
                        child: Icon(
                          Icons.restaurant,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (restaurante.endereco.isNotEmpty)
                    _LinhaInfo(icone: Icons.place, texto: restaurante.endereco),
                  if (restaurante.descricao.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(restaurante.descricao),
                  ],
                  if (restaurante.especialidades.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Especialidades',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: restaurante.especialidades
                          .map((e) => Chip(label: Text(e)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  const _LinhaInfo({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ],
    );
  }
}
