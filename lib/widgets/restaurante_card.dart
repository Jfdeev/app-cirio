import 'package:flutter/material.dart';

import '../models/restaurante.dart';

class RestauranteCard extends StatelessWidget {
  const RestauranteCard({super.key, required this.restaurante, required this.onTap});

  final Restaurante restaurante;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: const Icon(Icons.restaurant),
        ),
        title: Text(restaurante.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurante.endereco.isNotEmpty)
              Text(restaurante.endereco, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (restaurante.especialidades.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: -8,
                children: restaurante.especialidades
                    .take(3)
                    .map((e) => Chip(
                          label: Text(e, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        isThreeLine: restaurante.especialidades.isNotEmpty,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
