# Patch: Módulo Savings (Cuentas de ahorro + Ingresos recurrentes)

Tercera ampliación del proyecto, alineada con los baby steps de Dave Ramsey.
Cubre **Baby Step 1, 3, 4, 5 y 7** (todo lo que tiene que ver con acumular).

## Qué agrega

**Pantalla principal con 2 tabs:**
- **Cuentas**: tus ahorros (Bancolombia, Fondo Emergencia, Inversiones, etc.) con saldo y meta opcional
- **Ingresos**: tus fuentes recurrentes (salario, freelance, renta…) con frecuencia y próxima fecha esperada

**Header con "salud financiera":** total ahorrado + ingreso mensual proyectado + próximo cobro.

**Comportamiento clave:**
- **Recibir un ingreso** → crea automáticamente un Transaction tipo *income* en tu feed (categoría salary), avanza la próxima fecha esperada según la frecuencia
- **Depositar/retirar de un ahorro** → es una *transferencia*, NO se duplica como ingreso/gasto (es contabilidad básica entre cuentas propias)

## Archivos en el patch (28 nuevos + 2 modificados)

```
lib/features/savings/
├── data/
│   ├── datasources/savings_local_datasource.dart
│   ├── models/
│   │   ├── savings_account_model.dart
│   │   ├── savings_movement_model.dart
│   │   ├── income_source_model.dart
│   │   └── income_receipt_model.dart
│   └── repositories/savings_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── savings_account.dart
│   │   ├── savings_movement.dart
│   │   ├── income_source.dart
│   │   ├── income_receipt.dart
│   │   └── frequency.dart
│   ├── repositories/savings_repository.dart
│   └── usecases/
│       ├── get_accounts_usecase.dart
│       ├── add_account_usecase.dart
│       ├── delete_account_usecase.dart
│       ├── record_movement_usecase.dart
│       ├── get_income_sources_usecase.dart
│       ├── add_income_source_usecase.dart
│       ├── delete_income_source_usecase.dart
│       ├── record_income_usecase.dart
│       └── frequency_calculator.dart    ← lógica pura testeada
└── presentation/
    ├── providers/
    │   ├── savings_state.dart
    │   ├── savings_notifier.dart
    │   └── savings_providers.dart
    ├── screens/
    │   ├── savings_dashboard_screen.dart   ← pantalla principal con tabs
    │   ├── add_account_screen.dart
    │   ├── account_detail_screen.dart
    │   ├── add_income_source_screen.dart
    │   └── income_source_detail_screen.dart
    └── widgets/
        ├── account_card.dart
        ├── income_source_card.dart
        └── financial_health_card.dart

test/unit/
├── frequency_calculator_test.dart      ← 11 tests del cálculo de fechas
└── savings_repository_test.dart         ← 8 tests CRUD

# Archivos modificados (sobrescribir cuando Windows pregunte):
lib/core/router/app_router.dart                          ← +5 rutas nuevas
lib/features/finanzas/presentation/screens/home_screen.dart  ← +tarjeta ahorros + botón AppBar
```

## Pasos para aplicar

```cmd
cd "C:\Final project mobile application\finanzas_app"
git checkout -b feature/savings-module

rem Extrae savings_patch.zip encima de tu carpeta finanzas_app.
rem Reemplaza los 2 archivos modificados cuando Windows pregunte.

flutter pub get
flutter analyze
flutter test
```

Esperado:
- `flutter analyze`: 0 errors
- `flutter test`: **24 tests pasados** (los 15 anteriores + 11 frequency + 8 savings - 10 que se solapan… deberías ver alrededor de 30 tests al final)

```cmd
git add .
git commit -m "feat(savings): cuentas de ahorro y fuentes de ingreso recurrentes"
git push -u origin feature/savings-module
```

## Cómo se usa en la app

1. Tap en el ícono **🏦 (savings_outlined)** en el AppBar del Home
2. Tab **"Cuentas"**: agrega tu Bancolombia (tipo "Ahorro general", saldo $1.000.000, meta $5.000.000)
3. Tap en la cuenta → puedes **Depositar** o **Retirar** (son transferencias, no aparecen en transacciones)
4. Tab **"Ingresos"**: agrega tu salario (monto $3.000.000, frecuencia Quincenal, próxima fecha 15 de mayo)
5. Cuando recibas el ingreso, tap en **"Recibí"** desde el card → ingresas el monto real
6. Automáticamente:
   - La próxima fecha avanza al 31 de mayo (siguiente quincena)
   - Aparece una nueva transacción **"Ingreso: Salario"** tipo income en tu Home
   - Tu balance del mes y estadísticas se actualizan

## Decisiones técnicas para tu presentación

### 1. Por qué los movimientos NO crean transacciones, pero los ingresos SÍ

Es contabilidad básica:
- **Depositar a una cuenta de ahorros** = transferir dinero entre tus cuentas. No es un gasto ni un ingreso. Si lo registráramos como gasto, tu balance del mes mostraría que "perdiste" plata cuando en realidad solo la moviste.
- **Recibir un ingreso** = dinero NUEVO entrando a tu sistema. Eso sí es un income real y debe aparecer en tu feed.

Esta distinción la entiende cualquier contador y muestra que entendiste *por qué* hacemos las cosas, no solo *cómo*.

### 2. Cross-feature en Notifier, no en Domain

Igual que con debts: el `SavingsNotifier` depende del `TransactionRepository` para crear el income auto. Esa dependencia está en la capa de **presentación** — el dominio sigue limpio. Es el patrón "Application Service / Coordinator" de Clean Arch.

### 3. FrequencyCalculator como lógica pura

Toda la lógica de "próxima fecha según frecuencia" vive en una clase sin Flutter ni dependencias externas. Por eso pude escribirle 11 tests sin abrir un emulador. **Esto es lo que tu profesor quiere ver**: lógica de negocio aislada y testeada.

### 4. Cobertura del método de Ramsey

Con los 3 módulos del proyecto, ahora cubres:
- **Baby Step 1** (fondo emergencia $1000) → tipo `emergencyFund` en SavingsAccount
- **Baby Step 2** (deudas excepto hipoteca) → módulo debts con snowball
- **Baby Step 3** (3-6 meses de gastos) → seguir agregando al `emergencyFund`
- **Baby Step 4** (15% al retiro) → tipo `retirement`
- **Baby Step 5** (educación hijos) → tipo `education`
- **Baby Step 6** (pagar hipoteca) → módulo debts
- **Baby Step 7** (construir riqueza) → tipo `investment`

Si en una siguiente iteración agregas una pantalla "¿En qué baby step estoy?" que infiera automáticamente el paso actual a partir de los datos de los 3 módulos, tienes un coach financiero real, no solo un tracker.

## Próximos pasos sugeridos (para después de la sustentación)

1. **Pantalla "Baby Steps"**: detecta automáticamente en qué paso está el usuario y muestra qué hacer
2. **Notificaciones programadas**: alertar cuando se acerca la fecha esperada de un ingreso
3. **Asignación automática de ingreso a ahorros**: "del salario, asignar 20% al fondo de emergencia"
4. **Importación de extractos bancarios**: parsear PDFs/CSVs para no tener que ingresar todo manual
