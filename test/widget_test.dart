// Teste de smoke: garante que a tela inicial do app monta corretamente e
// exibe o título e os atalhos para as principais funcionalidades.

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:app_cirio/main.dart';

void main() {
  testWidgets('Tela inicial exibe o título e os atalhos principais',
      (WidgetTester tester) async {
    // Usa uma tela "alta" para garantir que os 6 atalhos da grade (em 3
    // linhas) sejam renderizados sem a necessidade de rolar a lista.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AppCirio());
    await tester.pump();

    expect(find.text('Círio de Nazaré'), findsOneWidget);
    expect(find.text('Notícias'), findsOneWidget);
    expect(find.text('Agenda Cultural'), findsOneWidget);
    expect(find.text('Gastronomia Paraense'), findsOneWidget);
    expect(find.text('Mapa do Círio'), findsOneWidget);
    expect(find.text('Como Chegar'), findsOneWidget);
    expect(find.text('Modo Orientação'), findsOneWidget);
  });
}
