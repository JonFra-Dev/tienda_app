// Smoke test: verifica que la app arranca sin lanzar excepciones.
// Reemplaza el widget_test.dart por defecto que genera `flutter create`.

import 'package:finanzas_app/app.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finanzas_app/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('La app arranca y muestra la pantalla de login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const FinanzasApp(),
      ),
    );
    // Permite que router y providers se inicialicen.
    await tester.pumpAndSettle();

    // En la primera carga sin sesión, el router redirige a /login.
    expect(find.text('Finanzas App'), findsOneWidget);
  });
}
