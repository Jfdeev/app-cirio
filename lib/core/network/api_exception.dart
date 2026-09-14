/// Erro lançado pelo [CirioApiService] quando uma chamada à API falha,
/// seja por problema de rede, timeout ou resposta com status inesperado.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
