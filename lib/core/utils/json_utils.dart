/// Pequenos utilitários para deixar o parsing dos JSONs da API mais
/// tolerante — a API pode representar números como int, double ou String,
/// dependendo do campo, e nem sempre todo campo opcional está presente.
class JsonUtils {
  JsonUtils._();

  static double asDouble(dynamic value, [double fallback = 0]) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static double? asDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String asString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String? asStringOrNull(dynamic value) => value?.toString();

  static List<String> asStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      // fallback defensivo, caso a API mande uma string separada por vírgula
      return value.split(',').map((e) => e.trim()).toList();
    }
    return const [];
  }
}
