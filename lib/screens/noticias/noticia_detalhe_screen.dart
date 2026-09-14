import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/noticia.dart';

class NoticiaDetalheScreen extends StatelessWidget {
  const NoticiaDetalheScreen({super.key, required this.noticia});

  final Noticia noticia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notícia')),
      body: ListView(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noticia.titulo,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (noticia.data.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    noticia.data,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
                const Divider(height: 32),
                Text(
                  noticia.conteudo.isNotEmpty
                      ? noticia.conteudo
                      : noticia.resumo,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
