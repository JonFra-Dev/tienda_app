# Finanzas App

App móvil Flutter para gestión de finanzas personales: tracker de presupuesto mensual, transacciones (ingresos/gastos) por categoría, estadísticas con gráficas y notificaciones de alerta de presupuesto.

Proyecto académico para "Full stack development with Flutter, Dart, and Python" — domina los requisitos mínimos del proyecto final.

---

## Cumplimiento de requisitos

### Funcionales

| Requisito | Implementación |
|---|---|
| 5+ pantallas con `go_router` | `/login`, `/register`, `/home`, `/add-transaction`, `/stats`, `/profile` (6 pantallas) |
| Autenticación de usuarios | Auth simulada con tokens en `SharedPreferences` (`AuthLocalDataSource`) |
| Consumo de API REST | `https://open.er-api.com/v6/latest/USD` para tasa USD→COP en pantalla de perfil |
| Persistencia local | `SharedPreferences` para usuarios, sesión, transacciones y presupuesto |
| Hardware nativo | `flutter_local_notifications` — alerta cuando el presupuesto llega al 80% / 100% |
| Loading & error states | `CircularProgressIndicator`, `ErrorView` reutilizable, `SnackBar`s, `RefreshIndicator` |

### Técnicos

| Requisito | Implementación |
|---|---|
| Clean Architecture (3 capas) | `presentation` / `domain` / `data` por feature |
| State Management | `flutter_riverpod` con `StateNotifier` (`AuthNotifier`, `TransactionsNotifier`) |
| Null Safety | Habilitado en `pubspec.yaml` (`sdk: '>=3.3.0 <4.0.0'`) |
| `flutter analyze` sin errores | `analysis_options.yaml` con `flutter_lints` |
| 5+ tests | 3 unit (`budget_calculator`, `auth_repository`, `transaction_repository`) + 2 widget (`login_screen`, `transaction_card`) |
| Material Design 3 + paleta | `useMaterial3: true`, paleta Indigo `#5C6BC0`, Yellow `#FFEE58`, Purple `#AB47BC`, fondo blanco/gris claro |
| Repositorio Git | Estructura lista, ver sección "Branches & commits sugeridos" |

---

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                       PRESENTATION                          │
│  Screens (UI)  →  Riverpod Notifiers  →  StateNotifier      │
│                          │                                  │
│                          ▼                                  │
│                                                             │
│                        DOMAIN                               │
│   Entities     UseCases       Repository (interfaces)       │
│   (User,       (LoginUC,         ▲                          │
│   Transaction) AddTxUC, …)       │ depende solo de abstr.   │
│                                                             │
│                          ▲                                  │
│                          │ implementa                       │
│                                                             │
│                         DATA                                │
│   Repository Impl   →   Datasources (Local, Remote)         │
│                              │                              │
│                              ▼                              │
│              SharedPreferences        HTTP (open.er-api.com)│
└─────────────────────────────────────────────────────────────┘
```

**Regla de dependencia**: `presentation` → `domain` ← `data`. La capa de dominio no depende de Flutter ni de paquetes externos (sólo de `equatable`).

### Estructura de carpetas

```
lib/
├── main.dart                  # Entry point — inicializa SharedPreferences y Notifications
├── app.dart                   # MaterialApp.router con tema y go_router
├── core/
│   ├── constants/             # Colores y strings centralizados
│   ├── theme/                 # AppTheme (Material Design 3)
│   ├── router/                # GoRouter con redirect basado en auth
│   ├── services/              # NotificationService (singleton)
│   ├── errors/                # Failure (sealed)
│   └── utils/                 # Result<T> (Success/Failure), Validators
├── features/
│   ├── auth/
│   │   ├── data/              # UserModel, AuthLocalDataSource, AuthRepositoryImpl
│   │   ├── domain/            # User, AuthRepository, LoginUC, RegisterUC, LogoutUC
│   │   └── presentation/      # AuthNotifier, AuthState, LoginScreen, RegisterScreen
│   └── finanzas/
│       ├── data/              # TransactionModel, datasources, repositories
│       ├── domain/            # Transaction, BudgetSummary, BudgetCalculator, etc.
│       └── presentation/      # TransactionsNotifier, screens, widgets
└── test/
    ├── unit/                  # 3 tests unitarios
    └── widget/                # 2 tests de widgets
```

---

## Decisiones técnicas

1. **Auth simulada con tokens**: Se usó `SharedPreferences` para guardar la "DB" de usuarios y un token base64 firmado (no criptográficamente seguro — sólo demo académica). Esto cumple el requisito sin requerir configuración de Firebase.
2. **API REST gratuita**: `open.er-api.com` no requiere API key y sirve para el uso académico. Se podría sustituir fácilmente por Firestore reemplazando el `ExchangeRateRepositoryImpl`.
3. **`Result<T>` propio en lugar de `dartz`/`fpdart`**: para reducir dependencias y dejar el patrón Either/Sealed visible en el código (Dart 3 sealed classes).
4. **Sin `build_runner`**: `Equatable` se usa manualmente en lugar de `freezed` para mantener la generación de código fuera del proyecto, siguiendo las convenciones del taller.
5. **Notificaciones locales**: Se elige `flutter_local_notifications` porque encaja temáticamente con la app de finanzas (alertas de presupuesto) y no requiere permisos especiales en iOS al estar en debug.
6. **Charts**: `fl_chart` para el `PieChart` de gastos por categoría (tema personalizado, sin dependencias web).

---

## Cómo correr el proyecto

### Pre-requisitos

- Flutter SDK 3.19+ (canal `stable`)
- Dart 3.3+
- Android Studio / Xcode con un emulador o dispositivo físico

### Pasos

```bash
# 1. Entrar al proyecto
cd finanzas_app

# 2. Instalar dependencias
flutter pub get

# 3. (Opcional) Crear las plataformas si Flutter no las creó solo
flutter create --platforms=android,ios .

# 4. Ejecutar la app
flutter run

# 5. Verificar análisis estático (debe salir SIN errores)
flutter analyze

# 6. Ejecutar todos los tests (5 tests deben pasar)
flutter test
```

> ⚠️ Nota: Si al hacer `flutter pub get` recibes un warning sobre la versión de un paquete, ejecuta `flutter pub upgrade --major-versions`.

---

## Branches & commits sugeridos para Git

```bash
git init
git add .
git commit -m "chore: initial scaffold with Clean Architecture"
git branch -M main

# Branches por feature (sugerido)
git checkout -b feature/auth
git commit -am "feat(auth): simulated authentication with tokens"
git checkout main && git merge feature/auth

git checkout -b feature/transactions
git commit -am "feat(finanzas): CRUD de transacciones con SharedPreferences"
git checkout main && git merge feature/transactions

git checkout -b feature/notifications
git commit -am "feat(core): notificaciones locales para alertas de presupuesto"
git checkout main && git merge feature/notifications

git checkout -b feature/tests
git commit -am "test: 3 unit + 2 widget tests"
git checkout main && git merge feature/tests
```

---

## Mapa de pantallas

| Ruta | Pantalla | Descripción |
|---|---|---|
| `/login` | `LoginScreen` | Email + password con validación |
| `/register` | `RegisterScreen` | Crear cuenta nueva |
| `/home` | `HomeScreen` | Resumen de balance, lista de transacciones, FAB |
| `/add-transaction` | `AddTransactionScreen` | Form con monto, descripción, categoría, fecha |
| `/stats` | `StatisticsScreen` | PieChart de gastos por categoría |
| `/profile` | `ProfileScreen` | Datos del usuario, tasa USD→COP, logout |

El router redirige automáticamente: si no hay sesión activa → `/login`; si ya está logueado y entra a `/login` → `/home`.

---

## Paleta de colores (Material Design 3)

| Color | Hex | Uso |
|---|---|---|
| Indigo | `#5C6BC0` | `seed`, primary, AppBar, botones |
| Purple | `#AB47BC` | secondary, FAB, links |
| Yellow | `#FFEE58` | tertiary, acentos en BudgetCard |
| Background | `#FAFAFA` | fondo de pantallas |
| Income | `#66BB6A` | montos de ingresos |
| Expense | `#EF5350` | montos de gastos, errores |

---

## Licencia

Proyecto académico — uso educativo.
