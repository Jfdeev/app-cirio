import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Encapsula acesso à localização do usuário (permissões, posição atual e
/// stream de atualizações) usando o pacote `geolocator`.
class LocationService {
  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  /// Garante que o serviço de localização está ligado e que o app tem
  /// permissão para usá-lo. Lança uma [Exception] com uma mensagem amigável
  /// quando isso não é possível.
  Future<void> ensurePermissao() async {
    final servicoLigado = await Geolocator.isLocationServiceEnabled();
    if (!servicoLigado) {
      throw Exception(
        'Ative o serviço de localização do aparelho para usar o mapa.',
      );
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão de localização negada. Habilite-a nas configurações do '
        'aparelho para ver sua posição no mapa.',
      );
    }
  }

  Future<LatLng> getPosicaoAtual() async {
    await ensurePermissao();
    final posicao = await Geolocator.getCurrentPosition(
      locationSettings: _settings,
    );
    return LatLng(posicao.latitude, posicao.longitude);
  }

  /// Stream contínua com a posição do usuário, já convertida para [LatLng].
  Stream<LatLng> get streamDePosicao => Geolocator.getPositionStream(
        locationSettings: _settings,
      ).map((p) => LatLng(p.latitude, p.longitude));

  /// Rumo (bearing), em graus (0-360, sentido horário a partir do norte),
  /// entre dois pontos — usado no modo de orientação para saber para onde
  /// a seta deve apontar.
  double calcularRumo(LatLng origem, LatLng destino) {
    final rumo = Geolocator.bearingBetween(
      origem.latitude,
      origem.longitude,
      destino.latitude,
      destino.longitude,
    );
    return (rumo + 360) % 360;
  }

  double calcularDistanciaMetros(LatLng origem, LatLng destino) {
    return Geolocator.distanceBetween(
      origem.latitude,
      origem.longitude,
      destino.latitude,
      destino.longitude,
    );
  }
}
