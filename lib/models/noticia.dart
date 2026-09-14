import '../core/utils/json_utils.dart';

/// Notícia relacionada à programação do Círio de Nazaré.
class Noticia {
  const Noticia({
    required this.id,
    required this.titulo,
    required this.data,
    required this.resumo,
    required this.imagem,
    required this.conteudo,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: JsonUtils.asString(json['id']),
      titulo: JsonUtils.asString(json['titulo']),
      data: JsonUtils.asString(json['data']),
      resumo: JsonUtils.asString(json['resumo']),
      imagem: JsonUtils.asString(json['imagem']),
      conteudo: JsonUtils.asString(json['conteudo']),
    );
  }

  final String id;
  final String titulo;
  final String data;
  final String resumo;
  final String imagem;
  final String conteudo;
}
