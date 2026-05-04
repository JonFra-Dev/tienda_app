/// Los 7 Baby Steps de Dave Ramsey, adaptados al contexto colombiano.
///
/// El orden importa: NO se puede saltar pasos. Cada paso construye el
/// momentum psicológico para el siguiente.
enum BabyStep {
  /// Step 1: Fondo de emergencia inicial (~$4M COP equivalente a $1000 USD)
  step1,

  /// Step 2: Pagar TODAS las deudas excepto hipoteca (snowball)
  step2,

  /// Step 3: Fondo de emergencia completo (3-6 meses de gastos)
  step3,

  /// Step 4: Invertir 15% de los ingresos en retiro
  step4,

  /// Step 5: Fondo de educación de los hijos
  step5,

  /// Step 6: Pagar la hipoteca completa
  step6,

  /// Step 7: Construir riqueza y dar
  step7;

  int get number => index + 1;

  String get title {
    switch (this) {
      case BabyStep.step1:
        return 'Baby Step 1';
      case BabyStep.step2:
        return 'Baby Step 2';
      case BabyStep.step3:
        return 'Baby Step 3';
      case BabyStep.step4:
        return 'Baby Step 4';
      case BabyStep.step5:
        return 'Baby Step 5';
      case BabyStep.step6:
        return 'Baby Step 6';
      case BabyStep.step7:
        return 'Baby Step 7';
    }
  }

  String get shortName {
    switch (this) {
      case BabyStep.step1:
        return 'Fondo emergencia inicial';
      case BabyStep.step2:
        return 'Pagar todas las deudas';
      case BabyStep.step3:
        return 'Fondo emergencia completo';
      case BabyStep.step4:
        return 'Invertir 15% al retiro';
      case BabyStep.step5:
        return 'Fondo educación hijos';
      case BabyStep.step6:
        return 'Pagar hipoteca';
      case BabyStep.step7:
        return 'Construir riqueza y dar';
    }
  }

  String get description {
    switch (this) {
      case BabyStep.step1:
        return 'Ahorra ~\$4.000.000 (equivalente a \$1.000 USD) como tu primer fondo de emergencia. Esto evita que un imprevisto te empuje a más deudas.';
      case BabyStep.step2:
        return 'Paga TODAS tus deudas (excepto hipoteca) usando el método Snowball: ataca la más pequeña primero, luego rueda hacia la siguiente.';
      case BabyStep.step3:
        return 'Construye tu fondo de emergencia hasta cubrir 3-6 meses de tus gastos. Este es tu colchón real ante crisis.';
      case BabyStep.step4:
        return 'Invierte el 15% de tus ingresos brutos en cuentas de retiro. Empieza el efecto del interés compuesto.';
      case BabyStep.step5:
        return 'Si tienes hijos, empieza a ahorrar para su educación universitaria.';
      case BabyStep.step6:
        return 'Acelera el pago de tu hipoteca. Cada peso extra reduce años de intereses.';
      case BabyStep.step7:
        return '¡Eres libre! Construye riqueza, disfruta tu vida y bendice a otros con generosidad.';
    }
  }

  String get actionLabel {
    switch (this) {
      case BabyStep.step1:
        return 'Aumenta tu fondo de emergencia';
      case BabyStep.step2:
        return 'Ataca la deuda más pequeña';
      case BabyStep.step3:
        return 'Sigue creciendo tu fondo';
      case BabyStep.step4:
        return 'Abre/aumenta tu cuenta de retiro';
      case BabyStep.step5:
        return 'Abre/aumenta tu cuenta de educación';
      case BabyStep.step6:
        return 'Aumenta los pagos de tu hipoteca';
      case BabyStep.step7:
        return '¡Disfruta y comparte!';
    }
  }
}
