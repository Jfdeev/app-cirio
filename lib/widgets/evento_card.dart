import 'package:flutter/material.dart';

import '../models/evento.dart';

class EventoCard extends StatelessWidget {
  const EventoCard({super.key, required this.evento});

  final Evento evento;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DataBadge(data: evento.data, horario: evento.horario),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.nome,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (evento.local.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.local,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (evento.descricao.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(evento.descricao),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataBadge extends StatelessWidget {
  const _DataBadge({required this.data, required this.horario});

  final String data;
  final String horario;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (horario.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              horario,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
