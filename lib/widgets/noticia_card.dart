import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/noticia.dart';

class NoticiaCard extends StatelessWidget {
  const NoticiaCard({super.key, required this.noticia, required this.onTap});

  final Noticia noticia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (noticia.imagem.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: noticia.imagem,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const ColoredBox(
                    color: Color(0x11000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: Color(0x11000000),
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    noticia.titulo,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (noticia.data.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      noticia.data,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (noticia.resumo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      noticia.resumo,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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
