import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/ambient_light_service.dart';
import 'services/cirio_api_service.dart';
import 'services/compass_service.dart';
import 'services/location_service.dart';
import 'state/theme_controller.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const AppCirio());
}

/// Raiz do aplicativo: registra os serviços compartilhados (API, GPS,
/// bússola e sensor de luz) e o controller de tema, e monta o [MaterialApp].
class AppCirio extends StatelessWidget {
  const AppCirio({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CirioApiService>(
          create: (_) => CirioApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<CompassService>(create: (_) => CompassService()),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(AmbientLightService()),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Círio de Nazaré',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.claro,
            darkTheme: AppTheme.escuro,
            themeMode: themeController.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
