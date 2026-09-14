import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre o app de mapas do aparelho (Google Maps, Apple Maps, etc.) já com
/// a rota até [destino] traçada — um atalho útil para quem prefere seguir
/// a navegação por voz de um app dedicado a partir da tela "Como chegar".
Future<bool> abrirRotaNoAppDeMapas(LatLng destino) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '&destination=${destino.latitude},${destino.longitude}'
    '&travelmode=walking',
  );
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
