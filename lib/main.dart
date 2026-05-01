import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Localización para formateo de fechas en español.
  await initializeDateFormatting('es_CO');

  // Inicializa SharedPreferences (persistencia local).
  final prefs = await SharedPreferences.getInstance();

  // Inicializa el servicio de notificaciones (hardware nativo).
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const FinanzasApp(),
    ),
  );
}
