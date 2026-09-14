/// Endereço base da API REST do Círio de Nazaré.
///
/// Repositório da API: https://gitlab.com/ricardo.casseb/cirio-belem-api
/// Documentação interativa (Swagger): $baseUrl/docs
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://cirio-belem-api.onrender.com';

  static const String noticias = '/noticias';
  static String noticia(String id) => '/noticias/$id';

  static const String eventos = '/eventos';
  static String evento(String id) => '/eventos/$id';

  static const String restaurantes = '/restaurantes';
  static String restaurante(String id) => '/restaurantes/$id';

  static const String mapaPontos = '/mapa/pontos';
  static const String mapaCirio = '/mapa/cirio';
  static const String mapaInicio = '/mapa/inicio';
  static const String mapaFim = '/mapa/fim';

  static const String rotaAteInicio = '/rota/ate-inicio';

  /// A API do Render entra em "sleep" quando fica sem tráfego; a primeira
  /// requisição após um período ocioso pode demorar bastante para acordar
  /// o serviço, então usamos um timeout mais generoso que o padrão.
  static const Duration timeout = Duration(seconds: 30);
}
