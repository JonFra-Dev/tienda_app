import 'package:finanzas_app/core/theme/app_theme.dart';
import 'package:finanzas_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:finanzas_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LoginScreen muestra campos email y password y valida vacío',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);

    // Tap submit con campos vacíos => valida y muestra errores
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pump();
    expect(find.text('Campo obligatorio'), findsWidgets);
  });

  testWidgets('LoginScreen valida formato de email inválido', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    final emailField = find.widgetWithText(TextFormField, 'Correo electrónico');
    final passField = find.widgetWithText(TextFormField, 'Contraseña');
    await tester.enterText(emailField, 'no-es-email');
    await tester.enterText(passField, '12345'); // < 6
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pump();

    expect(find.text('Correo no válido'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
  });
}
