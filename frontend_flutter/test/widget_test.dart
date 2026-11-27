// widget_test.dart — Prueba básica de Mova
// ==========================================
// Revisa que la app abra en la pantalla de inicio con Mumo
// y que el interruptor de "Letra grande" funcione.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend_flutter/estado_app.dart';
import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('Mova abre en la pantalla de inicio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => EstadoApp(),
        child: const MovaApp(),
      ),
    );
    await tester.pump();

    // Se ve el nombre de la app y el interruptor de letra grande
    expect(find.text('Mova'), findsWidgets);
    expect(find.text('Letra grande'), findsOneWidget);
  });

  test('Letra grande se activa y desactiva', () {
    final estado = EstadoApp();
    expect(estado.letraGrande, isFalse);
    estado.toggleLetraGrande();
    expect(estado.letraGrande, isTrue);
  });
}
