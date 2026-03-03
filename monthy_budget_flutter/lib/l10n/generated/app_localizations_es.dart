// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get navBudget => 'Presupuesto';

  @override
  String get navGrocery => 'Supermercado';

  @override
  String get navList => 'Lista';

  @override
  String get navCoach => 'Coach';

  @override
  String get navMeals => 'Comidas';

  @override
  String get navBudgetTooltip => 'Resumen del presupuesto mensual';

  @override
  String get navGroceryTooltip => 'Catálogo de productos';

  @override
  String get navListTooltip => 'Lista de la compra';

  @override
  String get navCoachTooltip => 'Coach financiero con IA';

  @override
  String get navMealsTooltip => 'Planificador de comidas';

  @override
  String get appTitle => 'Presupuesto Mensual';

  @override
  String get loading => 'Cargando...';

  @override
  String get loadingApp => 'Cargando la aplicación';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get clear => 'Limpiar';

  @override
  String errorSavingPurchase(String error) {
    return 'Error al guardar la compra: $error';
  }

  @override
  String filterBy(String label) {
    return 'Filtrar por $label';
  }

  @override
  String addToList(String name) {
    return 'Añadir $name a la lista';
  }

  @override
  String get enumMaritalSolteiro => 'Soltero/a';

  @override
  String get enumMaritalCasado => 'Casado/a';

  @override
  String get enumMaritalUniaoFacto => 'Pareja de hecho';

  @override
  String get enumMaritalDivorciado => 'Divorciado/a';

  @override
  String get enumMaritalViuvo => 'Viudo/a';

  @override
  String get enumSubsidyNone => 'Sin pagas extras';

  @override
  String get enumSubsidyFull => 'Con pagas extras';

  @override
  String get enumSubsidyHalf => '50% pagas extras';

  @override
  String get enumSubsidyNoneShort => 'Sin';

  @override
  String get enumSubsidyFullShort => 'Con';

  @override
  String get enumSubsidyHalfShort => '50%';

  @override
  String get enumMealAllowanceNone => 'Sin';

  @override
  String get enumMealAllowanceCard => 'Tarjeta';

  @override
  String get enumMealAllowanceCash => 'Efectivo';

  @override
  String get enumCatTelecomunicacoes => 'Telecomunicaciones';

  @override
  String get enumCatEnergia => 'Energía';

  @override
  String get enumCatAgua => 'Agua';

  @override
  String get enumCatAlimentacao => 'Alimentación';

  @override
  String get enumCatEducacao => 'Educación';

  @override
  String get enumCatHabitacao => 'Vivienda';

  @override
  String get enumCatTransportes => 'Transporte';

  @override
  String get enumCatSaude => 'Salud';

  @override
  String get enumCatLazer => 'Ocio';

  @override
  String get enumCatOutros => 'Otros';

  @override
  String get enumChartExpensesPie => 'Gastos por Categoría';

  @override
  String get enumChartIncomeVsExpenses => 'Ingresos vs Gastos';

  @override
  String get enumChartNetIncome => 'Ingreso Neto';

  @override
  String get enumChartDeductions => 'Deducciones (IRPF + SS)';

  @override
  String get enumChartSavingsRate => 'Tasa de Ahorro';

  @override
  String get enumMealBreakfast => 'Desayuno';

  @override
  String get enumMealLunch => 'Almuerzo';

  @override
  String get enumMealSnack => 'Merienda';

  @override
  String get enumMealDinner => 'Cena';

  @override
  String get enumObjMinimizeCost => 'Minimizar coste';

  @override
  String get enumObjBalancedHealth => 'Equilibrio coste/salud';

  @override
  String get enumObjHighProtein => 'Alta proteína';

  @override
  String get enumObjLowCarb => 'Bajo en carbohidratos';

  @override
  String get enumObjVegetarian => 'Vegetariano';

  @override
  String get enumEquipOven => 'Horno';

  @override
  String get enumEquipAirFryer => 'Freidora de aire';

  @override
  String get enumEquipFoodProcessor => 'Robot de cocina';

  @override
  String get enumEquipPressureCooker => 'Olla a presión';

  @override
  String get enumEquipMicrowave => 'Microondas';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'Sin restricción';

  @override
  String get enumSodiumReduced => 'Sodio reducido';

  @override
  String get enumSodiumLow => 'Bajo en sodio';

  @override
  String get enumAge0to3 => '0–3 años';

  @override
  String get enumAge4to10 => '4–10 años';

  @override
  String get enumAgeTeen => 'Adolescente';

  @override
  String get enumAgeAdult => 'Adulto';

  @override
  String get enumAgeSenior => 'Senior (65+)';

  @override
  String get enumActivitySedentary => 'Sedentario';

  @override
  String get enumActivityModerate => 'Moderado';

  @override
  String get enumActivityActive => 'Activo';

  @override
  String get enumActivityVeryActive => 'Muy activo';

  @override
  String get enumMedDiabetes => 'Diabetes';

  @override
  String get enumMedHypertension => 'Hipertensión';

  @override
  String get enumMedHighCholesterol => 'Colesterol alto';

  @override
  String get enumMedGout => 'Gota';

  @override
  String get enumMedIbs => 'Síndrome del intestino irritable';

  @override
  String get stressExcellent => 'Excelente';

  @override
  String get stressGood => 'Bueno';

  @override
  String get stressWarning => 'Atención';

  @override
  String get stressCritical => 'Crítico';

  @override
  String get stressFactorSavings => 'Tasa de ahorro';

  @override
  String get stressFactorSafety => 'Margen de seguridad';

  @override
  String get stressFactorFood => 'Presupuesto alimentación';

  @override
  String get stressFactorStability => 'Estabilidad gastos';

  @override
  String get stressStable => 'Estable';

  @override
  String get stressHigh => 'Elevada';

  @override
  String stressUsed(String percent) {
    return '$percent% usado';
  }

  @override
  String get stressNA => 'N/D';

  @override
  String monthReviewFoodExceeded(String percent) {
    return 'La alimentación superó el presupuesto en $percent% — considere revisar porciones o frecuencia de compras.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Los gastos reales superaron lo planificado en $amount€ — ¿ajustar valores en configuración?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Ahorró $amount€ más de lo previsto — puede reforzar el fondo de emergencia.';
  }

  @override
  String get monthReviewOnTrack =>
      'Gastos dentro de lo previsto. Buen control presupuestario.';

  @override
  String get dashboardTitle => 'Presupuesto Mensual';

  @override
  String get dashboardStressIndex => 'Índice de Tranquilidad';

  @override
  String get dashboardTension => 'Tensión';

  @override
  String get dashboardLiquidity => 'Liquidez';

  @override
  String get dashboardFinalPosition => 'Posición Final';

  @override
  String get dashboardMonth => 'Mes';

  @override
  String get dashboardGross => 'Bruto';

  @override
  String get dashboardNet => 'Neto';

  @override
  String get dashboardExpenses => 'Gastos';

  @override
  String get dashboardSavingsRate => 'Tasa Ahorro';

  @override
  String get dashboardViewTrends => 'Ver evolución';

  @override
  String get dashboardViewProjection => 'Ver proyección';

  @override
  String get dashboardFinancialSummary => 'RESUMEN FINANCIERO';

  @override
  String get dashboardOpenSettings => 'Abrir configuración';

  @override
  String get dashboardMonthlyLiquidity => 'LIQUIDEZ MENSUAL';

  @override
  String get dashboardPositiveBalance => 'Saldo positivo';

  @override
  String get dashboardNegativeBalance => 'Saldo negativo';

  @override
  String dashboardHeroLabel(String amount, String status) {
    return 'Liquidez mensual: $amount, $status';
  }

  @override
  String get dashboardConfigureData =>
      'Configure sus datos para ver el resumen.';

  @override
  String get dashboardOpenSettingsButton => 'Abrir Configuración';

  @override
  String get dashboardGrossIncome => 'Ingreso Bruto';

  @override
  String get dashboardNetIncome => 'Ingreso Neto';

  @override
  String dashboardInclMealAllowance(String amount) {
    return 'Incl. dieta comida: $amount';
  }

  @override
  String get dashboardDeductions => 'Deducciones';

  @override
  String dashboardIrsSs(String irs, String ss) {
    return 'IRPF: $irs | SS: $ss';
  }

  @override
  String dashboardExpensesAmount(String amount) {
    return 'Gastos: $amount';
  }

  @override
  String get dashboardSalaryDetail => 'DETALLE SALARIOS';

  @override
  String dashboardSalaryN(int n) {
    return 'Salario $n';
  }

  @override
  String get dashboardFood => 'ALIMENTACIÓN';

  @override
  String get dashboardSimulate => 'Simular';

  @override
  String get dashboardBudgeted => 'Presupuestado';

  @override
  String get dashboardSpent => 'Gastado';

  @override
  String get dashboardRemaining => 'Restante';

  @override
  String get dashboardFinalizePurchaseHint =>
      'Finaliza una compra en la Lista para registrar gastos.';

  @override
  String get dashboardPurchaseHistory => 'HISTORIAL DE COMPRAS';

  @override
  String get dashboardViewAll => 'Ver todo';

  @override
  String get dashboardAllPurchases => 'Todas las Compras';

  @override
  String dashboardPurchaseLabel(String date, String amount) {
    return 'Compra del $date, $amount';
  }

  @override
  String dashboardProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMonthlyExpenses => 'GASTOS MENSUALES';

  @override
  String get dashboardTotal => 'Total';

  @override
  String get dashboardGrossWithSubsidy => 'Bruto c/ pagas extras';

  @override
  String dashboardIrsRate(String rate) {
    return 'IRPF ($rate)';
  }

  @override
  String get dashboardSsRate => 'SS (11%)';

  @override
  String get dashboardMealAllowance => 'Dieta Comida';

  @override
  String get dashboardExemptIncome => 'Ing. Exento';

  @override
  String get dashboardDetails => 'Detalles';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs mes pasado';
  }

  @override
  String get dashboardPaceWarning => 'Gastando más rápido de lo previsto';

  @override
  String get dashboardPaceCritical =>
      'Riesgo de superar presupuesto alimentario';

  @override
  String get dashboardPace => 'Ritmo';

  @override
  String get dashboardProjection => 'Proyección';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actual€/día vs $expected€/día';
  }

  @override
  String get dashboardSummaryLabel => '— RESUMEN';

  @override
  String get dashboardViewMonthSummary => 'Ver resumen del mes';

  @override
  String get coachTitle => 'Coach Financiero';

  @override
  String get coachSubtitle => 'IA · GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Añade tu API key de OpenAI en Configuración para usar esta funcionalidad.';

  @override
  String get coachAnalysisTitle => 'Análisis financiero en 3 partes';

  @override
  String get coachAnalysisDescription =>
      'Posicionamiento general · Factores críticos del Índice de Tranquilidad · Oportunidad inmediata. Basado en tus datos reales de presupuesto, gastos e historial de compras.';

  @override
  String get coachConfigureApiKey => 'Configurar API key en Ajustes';

  @override
  String get coachApiKeyConfigured => 'API key configurada';

  @override
  String get coachAnalyzeButton => 'Analizar mi presupuesto';

  @override
  String get coachAnalyzing => 'Analizando...';

  @override
  String get coachCustomAnalysis => 'Análisis personalizado';

  @override
  String get coachNewAnalysis => 'Generar nuevo análisis';

  @override
  String get coachHistory => 'HISTORIAL';

  @override
  String get coachClearAll => 'Limpiar todo';

  @override
  String get coachClearTitle => 'Limpiar historial';

  @override
  String get coachClearContent =>
      '¿Estás seguro de que quieres eliminar todos los análisis guardados?';

  @override
  String get coachDeleteLabel => 'Eliminar análisis';

  @override
  String get coachDeleteTooltip => 'Eliminar';

  @override
  String get groceryTitle => 'Supermercado';

  @override
  String get grocerySearchHint => 'Buscar producto...';

  @override
  String get groceryLoadingLabel => 'Cargando productos';

  @override
  String get groceryLoadingMessage => 'Cargando productos...';

  @override
  String get groceryAll => 'Todos';

  @override
  String groceryProductCount(int count) {
    return '$count productos';
  }

  @override
  String groceryAddedToList(String name) {
    return '$name añadido a la lista';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit · precio medio';
  }

  @override
  String get shoppingTitle => 'Lista de la Compra';

  @override
  String get shoppingEmpty => 'Lista vacía';

  @override
  String get shoppingEmptyMessage =>
      'Añade productos desde la\npantalla Supermercado.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count por comprar · $total';
  }

  @override
  String get shoppingClear => 'Limpiar';

  @override
  String get shoppingFinalize => 'Finalizar Compra';

  @override
  String get shoppingEstimatedTotal => 'Total estimado';

  @override
  String get shoppingHowMuchSpent => '¿CUÁNTO GASTÉ EN TOTAL? (opcional)';

  @override
  String get shoppingConfirm => 'Confirmar';

  @override
  String get shoppingHistoryTooltip => 'Historial de compras';

  @override
  String get shoppingHistoryTitle => 'Historial de Compras';

  @override
  String shoppingItemChecked(String name) {
    return '$name, comprado';
  }

  @override
  String shoppingItemSwipe(String name) {
    return '$name, deslizar para eliminar';
  }

  @override
  String shoppingProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authRegister => 'Crear cuenta';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'ejemplo@email.com';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authLoginButton => 'Entrar';

  @override
  String get authRegisterButton => 'Registrarse';

  @override
  String get authSwitchToRegister => 'Crear cuenta nueva';

  @override
  String get authSwitchToLogin => 'Ya tengo cuenta';

  @override
  String get authRegistrationSuccess =>
      '¡Cuenta creada! Revisa tu email para verificar la cuenta antes de iniciar sesión.';

  @override
  String get householdSetupTitle => 'Configurar Hogar';

  @override
  String get householdCreate => 'Crear';

  @override
  String get householdJoinWithCode => 'Unirse con código';

  @override
  String get householdNameLabel => 'Nombre del hogar';

  @override
  String get householdNameHint => 'ej: Familia García';

  @override
  String get householdCodeLabel => 'Código de invitación';

  @override
  String get householdCodeHint => 'XXXXXX';

  @override
  String get householdCreateButton => 'Crear Hogar';

  @override
  String get householdJoinButton => 'Unirse al Hogar';

  @override
  String get householdNameRequired => 'Indica el nombre del hogar.';

  @override
  String get chartExpensesByCategory => 'Gastos por Categoría';

  @override
  String get chartIncomeVsExpenses => 'Ingresos vs Gastos';

  @override
  String get chartDeductions => 'Deducciones (IRPF + Seg. Social)';

  @override
  String get chartGrossVsNet => 'Ingreso Bruto vs Neto';

  @override
  String get chartSavingsRate => 'Tasa de Ahorro';

  @override
  String get chartNetIncome => 'Ing. Neto';

  @override
  String get chartExpensesLabel => 'Gastos';

  @override
  String get chartLiquidity => 'Liquidez';

  @override
  String chartSalaryN(int n) {
    return 'Sal. $n';
  }

  @override
  String get chartGross => 'Bruto';

  @override
  String get chartNet => 'Neto';

  @override
  String get chartNetSalary => 'Sal. Neto';

  @override
  String get chartIRS => 'IRPF';

  @override
  String get chartSocialSecurity => 'Seg. Social';

  @override
  String get chartSavings => 'ahorro';

  @override
  String projectionTitle(String month, String year) {
    return 'Proyección — $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'Gastó $spent de $budget en $days días';
  }

  @override
  String get projectionFood => 'ALIMENTACIÓN';

  @override
  String get projectionCurrentPace => 'Ritmo actual';

  @override
  String get projectionNoShopping => 'Sin compras';

  @override
  String get projectionReduce20 => '-20%';

  @override
  String projectionDailySpend(String amount) {
    return 'Gasto diario estimado: $amount/día';
  }

  @override
  String get projectionEndOfMonth => 'Proyección fin de mes';

  @override
  String get projectionRemaining => 'Restante proyectado';

  @override
  String get projectionStressImpact => 'Impacto en el Índice';

  @override
  String get projectionExpenses => 'GASTOS';

  @override
  String get projectionSimulation => 'Simulación — no guardado';

  @override
  String get projectionReduceAll => 'Reducir todas en ';

  @override
  String get projectionSimLiquidity => 'Liquidez simulada';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Tasa ahorro simulada';

  @override
  String get projectionSimIndex => 'Índice simulado';

  @override
  String get trendTitle => 'Evolución';

  @override
  String get trendStressIndex => 'ÍNDICE DE TRANQUILIDAD';

  @override
  String get trendTotalExpenses => 'GASTOS TOTALES';

  @override
  String get trendExpensesByCategory => 'GASTOS POR CATEGORÍA';

  @override
  String trendCurrent(String amount) {
    return 'Actual: $amount';
  }

  @override
  String get trendCatTelecom => 'Telecom';

  @override
  String get trendCatEnergy => 'Energía';

  @override
  String get trendCatWater => 'Agua';

  @override
  String get trendCatFood => 'Alimentación';

  @override
  String get trendCatEducation => 'Educación';

  @override
  String get trendCatHousing => 'Vivienda';

  @override
  String get trendCatTransport => 'Transporte';

  @override
  String get trendCatHealth => 'Salud';

  @override
  String get trendCatLeisure => 'Ocio';

  @override
  String get trendCatOther => 'Otros';

  @override
  String monthReviewTitle(String month) {
    return 'Resumen — $month';
  }

  @override
  String get monthReviewPlanned => 'Planificado';

  @override
  String get monthReviewActual => 'Real';

  @override
  String get monthReviewDifference => 'Diferencia';

  @override
  String get monthReviewFood => 'Alimentación';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual de $budget';
  }

  @override
  String get monthReviewTopDeviations => 'MAYORES DESVIACIONES';

  @override
  String get monthReviewSuggestions => 'SUGERENCIAS';

  @override
  String get monthReviewAiAnalysis => 'Análisis IA detallado';

  @override
  String get mealPlannerTitle => 'Planificador de Comidas';

  @override
  String get mealBudgetLabel => 'Presupuesto alimentación';

  @override
  String get mealPeopleLabel => 'Personas en el hogar';

  @override
  String get mealGeneratePlan => 'Generar Plan Mensual';

  @override
  String get mealGenerating => 'Generando...';

  @override
  String get mealRegenerateTitle => '¿Regenerar plan?';

  @override
  String get mealRegenerateContent => 'El plan actual será sustituido.';

  @override
  String get mealRegenerate => 'Regenerar';

  @override
  String mealWeekLabel(int n) {
    return 'Semana $n';
  }

  @override
  String mealWeekAbbr(int n) {
    return 'Sem.$n';
  }

  @override
  String get mealAddWeekToList => 'Añadir semana a la lista';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingredientes añadidos a la lista';
  }

  @override
  String mealDayLabel(int n) {
    return 'Día $n';
  }

  @override
  String get mealIngredients => 'Ingredientes';

  @override
  String get mealPreparation => 'Preparación';

  @override
  String get mealSwap => 'Cambiar';

  @override
  String get mealConsolidatedList => 'Ver lista consolidada';

  @override
  String get mealConsolidatedTitle => 'Lista Consolidada';

  @override
  String get mealAlternatives => 'Alternativas';

  @override
  String mealTotalCost(String cost) {
    return '$cost€ total';
  }

  @override
  String get mealCatProteins => 'Proteínas';

  @override
  String get mealCatVegetables => 'Verduras';

  @override
  String get mealCatCarbs => 'Carbohidratos';

  @override
  String get mealCatFats => 'Grasas';

  @override
  String get mealCatCondiments => 'Condimentos';

  @override
  String mealCostPerPerson(String cost) {
    return '$cost€/pers';
  }

  @override
  String get mealNutriProt => 'prot';

  @override
  String get mealNutriCarbs => 'carbs';

  @override
  String get mealNutriFat => 'grasa';

  @override
  String get mealNutriFiber => 'fibra';

  @override
  String get wizardStepMeals => 'Comidas';

  @override
  String get wizardStepObjective => 'Objetivo';

  @override
  String get wizardStepRestrictions => 'Restricciones';

  @override
  String get wizardStepKitchen => 'Cocina';

  @override
  String get wizardStepStrategy => 'Estrategia';

  @override
  String get wizardMealsQuestion =>
      '¿Qué comidas quieres incluir en el plan diario?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight del presupuesto';
  }

  @override
  String get wizardObjectiveQuestion =>
      '¿Cuál es el objetivo principal de tu plan alimentario?';

  @override
  String wizardSelected(String label) {
    return '$label, seleccionado';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRICCIONES DIETÉTICAS';

  @override
  String get wizardGlutenFree => 'Sin gluten';

  @override
  String get wizardLactoseFree => 'Sin lactosa';

  @override
  String get wizardNutFree => 'Sin frutos secos';

  @override
  String get wizardShellfishFree => 'Sin marisco';

  @override
  String get wizardDislikedIngredients => 'INGREDIENTES QUE NO TE GUSTAN';

  @override
  String get wizardDislikedHint => 'ej: atún, brócoli';

  @override
  String get wizardMaxPrepTime => 'TIEMPO MÁXIMO POR COMIDA';

  @override
  String get wizardMaxComplexity => 'COMPLEJIDAD MÁXIMA';

  @override
  String get wizardComplexityEasy => 'Fácil';

  @override
  String get wizardComplexityMedium => 'Medio';

  @override
  String get wizardComplexityAdvanced => 'Avanzado';

  @override
  String get wizardEquipment => 'EQUIPAMIENTO DISPONIBLE';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc => 'Cocinar para varios días a la vez';

  @override
  String get wizardMaxBatchDays => 'MÁXIMO DE DÍAS POR RECETA';

  @override
  String wizardBatchDays(int days) {
    return '$days días';
  }

  @override
  String get wizardPreferredCookingDay => 'DÍA PREFERIDO PARA COCINAR';

  @override
  String get wizardReuseLeftovers => 'Reutilizar sobras';

  @override
  String get wizardReuseLeftoversDesc =>
      'La cena de ayer = almuerzo de hoy (coste 0)';

  @override
  String get wizardMaxNewIngredients =>
      'MÁXIMO DE INGREDIENTES NUEVOS POR SEMANA';

  @override
  String get wizardNoLimit => 'Sin límite';

  @override
  String get wizardMinimizeWaste => 'Minimizar desperdicio';

  @override
  String get wizardMinimizeWasteDesc =>
      'Preferir recetas que reutilicen ingredientes ya usados';

  @override
  String get wizardSettingsInfo =>
      'Puedes cambiar la configuración del planificador en cualquier momento en Ajustes → Comidas.';

  @override
  String get wizardContinue => 'Continuar';

  @override
  String get wizardGeneratePlan => 'Generar Plan';

  @override
  String wizardStepOf(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get wizardWeekdayMon => 'Lun';

  @override
  String get wizardWeekdayTue => 'Mar';

  @override
  String get wizardWeekdayWed => 'Mié';

  @override
  String get wizardWeekdayThu => 'Jue';

  @override
  String get wizardWeekdayFri => 'Vie';

  @override
  String get wizardWeekdaySat => 'Sáb';

  @override
  String get wizardWeekdaySun => 'Dom';

  @override
  String wizardPrepMin(int mins) {
    return '${mins}min';
  }

  @override
  String get wizardPrepMin60Plus => '60+';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsPersonal => 'Datos Personales';

  @override
  String get settingsSalaries => 'Salarios';

  @override
  String get settingsExpenses => 'Presupuesto y Facturas';

  @override
  String get settingsCoachAi => 'Coach IA';

  @override
  String get settingsDashboard => 'Panel';

  @override
  String get settingsMeals => 'Comidas';

  @override
  String get settingsRegion => 'Región e Idioma';

  @override
  String get settingsCountry => 'País';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsMaritalStatus => 'Estado civil';

  @override
  String get settingsDependents => 'Dependientes';

  @override
  String get settingsDisability => 'Discapacidad';

  @override
  String get settingsGrossSalary => 'Salario bruto';

  @override
  String get settingsTitulares => 'Titulares';

  @override
  String get settingsSubsidyMode => 'Pagas extras';

  @override
  String get settingsMealAllowance => 'Dieta de comida';

  @override
  String get settingsMealAllowancePerDay => 'Importe/día';

  @override
  String get settingsWorkingDays => 'Días laborables/mes';

  @override
  String get settingsOtherExemptIncome => 'Otros ingresos exentos';

  @override
  String get settingsAddSalary => 'Añadir salario';

  @override
  String get settingsAddExpense => 'Añadir categoría';

  @override
  String get settingsExpenseName => 'Nombre de categoría';

  @override
  String get settingsExpenseAmount => 'Importe';

  @override
  String get settingsExpenseCategory => 'Categoría';

  @override
  String get settingsApiKey => 'API Key OpenAI';

  @override
  String get settingsInviteCode => 'Código de invitación';

  @override
  String get settingsCopyCode => 'Copiar';

  @override
  String get settingsCodeCopied => '¡Código copiado!';

  @override
  String get settingsAdminOnly =>
      'Solo el administrador puede editar la configuración.';

  @override
  String get settingsShowSummaryCards => 'Mostrar tarjetas resumen';

  @override
  String get settingsEnabledCharts => 'Gráficos activos';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirmTitle => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirmContent =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settingsLogoutConfirmButton => 'Cerrar sesión';

  @override
  String get settingsSalariesSection => 'Ingresos';

  @override
  String get settingsExpensesMonthly => 'Presupuesto y Facturas';

  @override
  String get settingsFavorites => 'Productos Favoritos';

  @override
  String get settingsCoachOpenAi => 'Coach IA (OpenAI)';

  @override
  String get settingsHousehold => 'Hogar';

  @override
  String get settingsMaritalStatusLabel => 'ESTADO CIVIL';

  @override
  String get settingsDependentsLabel => 'NÚMERO DE DEPENDIENTES';

  @override
  String settingsSocialSecurityRate(String rate) {
    return 'Seguridad Social: $rate';
  }

  @override
  String get settingsSalaryActive => 'Activo';

  @override
  String get settingsGrossMonthlySalary => 'SALARIO BRUTO MENSUAL';

  @override
  String get settingsSubsidyHoliday => 'PAGAS EXTRAS DE VACACIONES Y NAVIDAD';

  @override
  String get settingsOtherExemptLabel => 'OTROS INGRESOS EXENTOS DE IMPUESTOS';

  @override
  String get settingsMealAllowanceLabel => 'DIETA DE COMIDA';

  @override
  String get settingsAmountPerDay => 'IMPORTE/DÍA';

  @override
  String get settingsDaysPerMonth => 'DÍAS/MES';

  @override
  String get settingsTitularesLabel => 'N. TITULARES';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Titular$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'Añadir salario';

  @override
  String get settingsAddExpenseButton => 'Añadir Categoría';

  @override
  String get settingsDeviceLocal =>
      'Estos ajustes se guardan localmente en este dispositivo.';

  @override
  String get settingsVisibleSections => 'SECCIONES VISIBLES';

  @override
  String get settingsMinimalist => 'Minimalista';

  @override
  String get settingsFull => 'Completo';

  @override
  String get settingsDashMonthlyLiquidity => 'Liquidez mensual';

  @override
  String get settingsDashStressIndex => 'Índice de Tranquilidad';

  @override
  String get settingsDashSummaryCards => 'Tarjetas resumen';

  @override
  String get settingsDashSalaryBreakdown => 'Detalle por salario';

  @override
  String get settingsDashFood => 'Alimentación';

  @override
  String get settingsDashPurchaseHistory => 'Historial de compras';

  @override
  String get settingsDashExpensesBreakdown => 'Desglose de gastos';

  @override
  String get settingsDashMonthReview => 'Revisión del mes';

  @override
  String get settingsDashCharts => 'Gráficos';

  @override
  String get dashGroupOverview => 'RESUMEN';

  @override
  String get dashGroupFinancialDetail => 'DETALLE FINANCIERO';

  @override
  String get dashGroupHistory => 'HISTORIAL';

  @override
  String get dashGroupCharts => 'GRÁFICOS';

  @override
  String get settingsVisibleCharts => 'GRÁFICOS VISIBLES';

  @override
  String get settingsFavTip =>
      'Los productos favoritos influyen en el plan de comidas — las recetas con esos ingredientes tienen prioridad.';

  @override
  String get settingsMyFavorites => 'MIS FAVORITOS';

  @override
  String get settingsProductCatalog => 'CATÁLOGO DE PRODUCTOS';

  @override
  String get settingsSearchProduct => 'Buscar producto...';

  @override
  String get settingsLoadingProducts => 'Cargando productos...';

  @override
  String get settingsAddIngredient => 'Añadir ingrediente';

  @override
  String get settingsIngredientName => 'Nombre del ingrediente';

  @override
  String get settingsAddButton => 'Añadir';

  @override
  String get settingsAddToPantry => 'Añadir a la despensa';

  @override
  String get settingsHouseholdPeople => 'HOGAR (PERSONAS)';

  @override
  String get settingsAutomatic => '(auto)';

  @override
  String get settingsUseAutoValue => 'Usar valor automático';

  @override
  String settingsManualValue(int count) {
    return 'Valor manual: $count personas';
  }

  @override
  String settingsAutoValue(int count) {
    return 'Calculado automáticamente: $count (titulares + dependientes)';
  }

  @override
  String get settingsHouseholdMembers => 'MIEMBROS DEL HOGAR';

  @override
  String get settingsPortions => 'porciones';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Equivalente total: $total porciones';
  }

  @override
  String get settingsAddMember => 'Añadir miembro';

  @override
  String get settingsPreferSeasonal => 'Preferir recetas de temporada';

  @override
  String get settingsPreferSeasonalDesc =>
      'Prioriza recetas de la temporada actual';

  @override
  String get settingsNutritionalGoals => 'OBJETIVOS NUTRICIONALES';

  @override
  String get settingsCalorieHint => 'ej: 2000';

  @override
  String get settingsKcalPerDay => 'kcal/día';

  @override
  String get settingsProteinHint => 'ej: 60';

  @override
  String get settingsGramsPerDay => 'g/día';

  @override
  String get settingsFiberHint => 'ej: 25';

  @override
  String get settingsDailyProtein => 'Proteína diaria';

  @override
  String get settingsDailyFiber => 'Fibra diaria';

  @override
  String get settingsMedicalConditions => 'CONDICIONES MÉDICAS';

  @override
  String get settingsActiveMeals => 'COMIDAS ACTIVAS';

  @override
  String get settingsObjective => 'OBJETIVO';

  @override
  String get settingsVeggieDays => 'DÍAS VEGETARIANOS POR SEMANA';

  @override
  String get settingsDietaryRestrictions => 'RESTRICCIONES DIETÉTICAS';

  @override
  String get settingsEggFree => 'Sin huevos';

  @override
  String get settingsSodiumPref => 'PREFERENCIA DE SODIO';

  @override
  String get settingsDislikedIngredients => 'INGREDIENTES NO DESEADOS';

  @override
  String get settingsExcludedProteins => 'PROTEÍNAS EXCLUIDAS';

  @override
  String get settingsProteinChicken => 'Pollo';

  @override
  String get settingsProteinGroundMeat => 'Carne Picada';

  @override
  String get settingsProteinPork => 'Cerdo';

  @override
  String get settingsProteinHake => 'Merluza';

  @override
  String get settingsProteinCod => 'Bacalao';

  @override
  String get settingsProteinSardine => 'Sardina';

  @override
  String get settingsProteinTuna => 'Atún';

  @override
  String get settingsProteinEgg => 'Huevos';

  @override
  String get settingsMaxPrepTime => 'TIEMPO MÁXIMO (MINUTOS)';

  @override
  String settingsMaxComplexity(int value) {
    return 'COMPLEJIDAD MÁXIMA ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'TIEMPO FIN DE SEMANA (MINUTOS)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'COMPLEJIDAD FIN DE SEMANA ($value/5)';
  }

  @override
  String get settingsEatingOutDays => 'DÍAS DE COMER FUERA';

  @override
  String get settingsWeeklyDistribution => 'DISTRIBUCIÓN SEMANAL';

  @override
  String settingsFishPerWeek(String count) {
    return 'Pescado por semana: $count';
  }

  @override
  String get settingsNoMinimum => 'sin mínimo';

  @override
  String settingsLegumePerWeek(String count) {
    return 'Legumbres por semana: $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Carne roja máx/semana: $count';
  }

  @override
  String get settingsNoLimit => 'sin límite';

  @override
  String get settingsAvailableEquipment => 'EQUIPAMIENTO DISPONIBLE';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'MÁXIMO DE DÍAS POR RECETA';

  @override
  String get settingsReuseLeftovers => 'Reutilizar sobras';

  @override
  String get settingsMinimizeWaste => 'Minimizar desperdicio';

  @override
  String get settingsPrioritizeLowCost => 'Priorizar bajo coste';

  @override
  String get settingsPrioritizeLowCostDesc => 'Preferir recetas más económicas';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'INGREDIENTES NUEVOS POR SEMANA ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'Almuerzos para llevar';

  @override
  String get settingsLunchboxLunchesDesc =>
      'Solo recetas transportables para el almuerzo';

  @override
  String get settingsPantry => 'DESPENSA (SIEMPRE EN STOCK)';

  @override
  String get settingsResetWizard => 'Restablecer Asistente';

  @override
  String get settingsApiKeyInfo =>
      'La clave se guarda localmente en el dispositivo y nunca se comparte. Usa el modelo GPT-4o mini (~€0,00008 por análisis).';

  @override
  String get settingsInviteCodeLabel => 'CÓDIGO DE INVITACIÓN';

  @override
  String get settingsGenerateInvite => 'Generar código de invitación';

  @override
  String get settingsShareWithMembers => 'Compartir con miembros del hogar';

  @override
  String get settingsNewCode => 'Nuevo código';

  @override
  String get settingsCodeValidInfo =>
      'El código es válido por 7 días. Compártelo con quien quieras añadir al hogar.';

  @override
  String get settingsName => 'Nombre';

  @override
  String get settingsAgeGroup => 'Grupo de edad';

  @override
  String get settingsActivityLevel => 'Nivel de actividad';

  @override
  String settingsSalaryN(int n) {
    return 'Salario $n';
  }

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryES => 'España';

  @override
  String get countryFR => 'Francia';

  @override
  String get countryUK => 'Reino Unido';

  @override
  String get langPT => 'Português';

  @override
  String get langEN => 'English';

  @override
  String get langFR => 'Français';

  @override
  String get langES => 'Español';

  @override
  String get langSystem => 'Sistema';

  @override
  String get taxIncomeTax => 'Impuesto sobre la renta';

  @override
  String get taxSocialContribution => 'Contribución social';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'Seguridad Social';

  @override
  String get taxIRPF => 'IRPF';

  @override
  String get taxSSSpain => 'Seguridad Social';

  @override
  String get taxIR => 'Impôt sur le Revenu';

  @override
  String get taxCSG => 'CSG + CRDS';

  @override
  String get taxPAYE => 'Income Tax';

  @override
  String get taxNI => 'National Insurance';

  @override
  String get enumSubsidyEsNone => 'Sin pagas extras';

  @override
  String get enumSubsidyEsFull => 'Con pagas extras';

  @override
  String get enumSubsidyEsHalf => '50% pagas extras';

  @override
  String get aiCoachSystemPrompt =>
      'Eres un analista financiero personal para usuarios portugueses. Responde siempre en portugués europeo. Sé directo y analítico — usa siempre números concretos del contexto proporcionado. Estructura la respuesta exactamente en las 3 partes pedidas. No introduzcas datos, benchmarks o referencias externas no proporcionados.';

  @override
  String get aiCoachInvalidApiKey =>
      'API key inválida. Verifica en Configuración.';

  @override
  String get aiCoachMidMonthSystem =>
      'Eres un consultor de presupuesto doméstico portugués. Responde siempre en portugués europeo. Sé práctico y directo.';

  @override
  String get aiMealPlannerSystem =>
      'Eres un chef portugués. Responde siempre en portugués europeo. Responde SOLO con JSON válido, sin texto adicional.';

  @override
  String get monthAbbrJan => 'Ene';

  @override
  String get monthAbbrFeb => 'Feb';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Abr';

  @override
  String get monthAbbrMay => 'May';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Ago';

  @override
  String get monthAbbrSep => 'Sep';

  @override
  String get monthAbbrOct => 'Oct';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dic';

  @override
  String get monthFullJan => 'Enero';

  @override
  String get monthFullFeb => 'Febrero';

  @override
  String get monthFullMar => 'Marzo';

  @override
  String get monthFullApr => 'Abril';

  @override
  String get monthFullMay => 'Mayo';

  @override
  String get monthFullJun => 'Junio';

  @override
  String get monthFullJul => 'Julio';

  @override
  String get monthFullAug => 'Agosto';

  @override
  String get monthFullSep => 'Septiembre';

  @override
  String get monthFullOct => 'Octubre';

  @override
  String get monthFullNov => 'Noviembre';

  @override
  String get monthFullDec => 'Diciembre';

  @override
  String get setupWizardWelcomeTitle => 'Bienvenido a tu presupuesto';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Vamos a configurar lo esencial para que tu panel esté listo.';

  @override
  String get setupWizardBullet1 => 'Calcular tu salario neto';

  @override
  String get setupWizardBullet2 => 'Organizar tus gastos';

  @override
  String get setupWizardBullet3 => 'Ver cuánto te queda cada mes';

  @override
  String get setupWizardReassurance =>
      'Puedes cambiarlo todo más tarde en ajustes.';

  @override
  String get setupWizardStart => 'Empezar';

  @override
  String get setupWizardSkipAll => 'Saltar configuración';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get setupWizardContinue => 'Continuar';

  @override
  String get setupWizardCountryTitle => '¿Dónde vives?';

  @override
  String get setupWizardCountrySubtitle =>
      'Esto define el sistema fiscal, la moneda y los valores por defecto.';

  @override
  String get setupWizardLanguage => 'Idioma';

  @override
  String get setupWizardLangSystem => 'Predeterminado del sistema';

  @override
  String get setupWizardCountryPT => 'Portugal';

  @override
  String get setupWizardCountryES => 'España';

  @override
  String get setupWizardCountryFR => 'Francia';

  @override
  String get setupWizardCountryUK => 'Reino Unido';

  @override
  String get setupWizardPersonalTitle => 'Información personal';

  @override
  String get setupWizardPersonalSubtitle =>
      'Usamos esto para calcular tus impuestos con más precisión.';

  @override
  String get setupWizardPrivacyNote =>
      'Tus datos se quedan en tu cuenta y nunca se comparten.';

  @override
  String get setupWizardSingle => 'Soltero/a';

  @override
  String get setupWizardMarried => 'Casado/a';

  @override
  String get setupWizardDependents => 'Dependientes';

  @override
  String get setupWizardTitulares => 'Titulares fiscales';

  @override
  String get setupWizardSalaryTitle => '¿Cuál es tu salario?';

  @override
  String get setupWizardSalarySubtitle =>
      'Introduce el importe bruto mensual. Calculamos el neto automáticamente.';

  @override
  String get setupWizardSalaryGross => 'Salario bruto mensual';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'Neto estimado: $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Puedes añadir más fuentes de ingreso más tarde.';

  @override
  String get setupWizardSalarySkip => 'Saltar este paso';

  @override
  String get setupWizardExpensesTitle => 'Tus gastos mensuales';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valores sugeridos para tu país. Ajusta según necesites.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Puedes añadir más categorías más tarde.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'Neto: $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'Gastos: $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'Disponible: $amount';
  }

  @override
  String get setupWizardFinish => 'Finalizar';

  @override
  String get setupWizardCompleteTitle => '¡Todo listo!';

  @override
  String get setupWizardCompleteReassurance =>
      'Tu presupuesto está configurado. Puedes ajustarlo todo en ajustes en cualquier momento.';

  @override
  String get setupWizardGoToDashboard => 'Ver mi presupuesto';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configura tu salario en ajustes para ver el cálculo completo.';

  @override
  String get setupWizardExpRent => 'Alquiler / Hipoteca';

  @override
  String get setupWizardExpGroceries => 'Alimentación';

  @override
  String get setupWizardExpTransport => 'Transporte';

  @override
  String get setupWizardExpUtilities => 'Suministros (luz, agua, gas)';

  @override
  String get setupWizardExpTelecom => 'Telecomunicaciones';

  @override
  String get setupWizardExpHealth => 'Salud';

  @override
  String get setupWizardExpLeisure => 'Ocio';

  @override
  String get expenseTrackerTitle => 'PRESUPUESTO VS REAL';

  @override
  String get expenseTrackerBudgeted => 'Presupuestado';

  @override
  String get expenseTrackerActual => 'Real';

  @override
  String get expenseTrackerRemaining => 'Restante';

  @override
  String get expenseTrackerOver => 'Sobrepasado';

  @override
  String get expenseTrackerViewAll => 'Ver detalles';

  @override
  String get expenseTrackerNoExpenses => 'Sin gastos registrados.';

  @override
  String get expenseTrackerScreenTitle => 'Control de Gastos';

  @override
  String expenseTrackerMonthTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get expenseTrackerDeleteConfirm => '¿Eliminar este gasto?';

  @override
  String get expenseTrackerEmpty =>
      'Sin gastos este mes.\nToca + para añadir el primero.';

  @override
  String get addExpenseTitle => 'Añadir Gasto';

  @override
  String get editExpenseTitle => 'Editar Gasto';

  @override
  String get addExpenseCategory => 'Categoría';

  @override
  String get addExpenseAmount => 'Importe';

  @override
  String get addExpenseDate => 'Fecha';

  @override
  String get addExpenseDescription => 'Descripción (opcional)';

  @override
  String get addExpenseCustomCategory => 'Categoría personalizada';

  @override
  String get addExpenseInvalidAmount => 'Introduce un importe válido';

  @override
  String get addExpenseTooltip => 'Registrar gasto';

  @override
  String get addExpenseItem => 'Gasto';

  @override
  String get addExpenseOthers => 'Otros';

  @override
  String get settingsDashBudgetVsActual => 'Presupuesto vs Real';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get recurringExpenses => 'Facturas Mensuales';

  @override
  String get recurringExpenseAdd => 'Añadir Factura';

  @override
  String get recurringExpenseEdit => 'Editar Factura';

  @override
  String get recurringExpenseCategory => 'Categoría';

  @override
  String get recurringExpenseAmount => 'Importe';

  @override
  String get recurringExpenseDescription => 'Descripción (opcional)';

  @override
  String get recurringExpenseDayOfMonth => 'Día de vencimiento';

  @override
  String get recurringExpenseActive => 'Activo';

  @override
  String get recurringExpenseInactive => 'Inactivo';

  @override
  String get recurringExpenseEmpty =>
      'Sin facturas mensuales.\nAñade una para generarla automáticamente cada mes.';

  @override
  String get recurringExpenseDeleteConfirm => '¿Eliminar esta factura?';

  @override
  String get recurringExpenseAutoCreated => 'Creado automáticamente';

  @override
  String get recurringExpenseManage => 'Gestionar facturas';

  @override
  String get recurringExpenseMarkRecurring => 'Marcar como factura mensual';

  @override
  String get recurringExpensePopulated =>
      'Facturas mensuales generadas para este mes';

  @override
  String get recurringExpenseDayHint => 'Ej: 1 para el día 1';

  @override
  String get recurringExpenseNoDay => 'Sin día fijo';

  @override
  String get recurringExpenseSaved => 'Factura guardada';

  @override
  String billsCount(int count) {
    return '$count facturas';
  }

  @override
  String get billsNone => 'Sin facturas';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count facturas · $amount/mes';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Facturas ($amount) superan presupuesto';
  }

  @override
  String get billsAddBill => 'Añadir Factura';

  @override
  String get billsBudgetSettings => 'Configuración del Presupuesto';

  @override
  String get billsRecurringBills => 'Facturas Recurrentes';

  @override
  String get billsDescription => 'Descripción';

  @override
  String get billsAmount => 'Importe';

  @override
  String get billsDueDay => 'Día de vencimiento';

  @override
  String get billsActive => 'Activa';

  @override
  String get expenseTrends => 'Tendencias de Gastos';

  @override
  String get expenseTrendsViewTrends => 'Ver Tendencias';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'Presupuestado';

  @override
  String get expenseTrendsActual => 'Real';

  @override
  String get expenseTrendsByCategory => 'Por Categoría';

  @override
  String get expenseTrendsNoData =>
      'Datos insuficientes para mostrar tendencias.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'Media';

  @override
  String get expenseTrendsOverview => 'Resumen';

  @override
  String get expenseTrendsMonthly => 'Mensual';

  @override
  String get savingsGoals => 'Objetivos de Ahorro';

  @override
  String get savingsGoalAdd => 'Nuevo Objetivo';

  @override
  String get savingsGoalEdit => 'Editar Objetivo';

  @override
  String get savingsGoalName => 'Nombre del objetivo';

  @override
  String get savingsGoalTarget => 'Importe objetivo';

  @override
  String get savingsGoalCurrent => 'Importe actual';

  @override
  String get savingsGoalDeadline => 'Fecha límite';

  @override
  String get savingsGoalNoDeadline => 'Sin fecha límite';

  @override
  String get savingsGoalColor => 'Color';

  @override
  String savingsGoalProgress(String percent) {
    return '$percent% alcanzado';
  }

  @override
  String savingsGoalRemaining(String amount) {
    return 'Faltan $amount';
  }

  @override
  String get savingsGoalCompleted => '¡Objetivo alcanzado!';

  @override
  String get savingsGoalEmpty =>
      'Sin objetivos de ahorro.\nCrea uno para seguir tu progreso.';

  @override
  String get savingsGoalDeleteConfirm => '¿Eliminar este objetivo?';

  @override
  String get savingsGoalContribute => 'Contribuir';

  @override
  String get savingsGoalContributionAmount => 'Importe de contribución';

  @override
  String get savingsGoalContributionNote => 'Nota (opcional)';

  @override
  String get savingsGoalContributionDate => 'Fecha';

  @override
  String get savingsGoalContributionHistory => 'Historial de Contribuciones';

  @override
  String get savingsGoalSeeAll => 'Ver todos';

  @override
  String savingsGoalSurplusSuggestion(String amount) {
    return 'Tuviste $amount de excedente el mes pasado — ¿quieres asignar a un objetivo?';
  }

  @override
  String get savingsGoalAllocate => 'Asignar';

  @override
  String get savingsGoalSaved => 'Objetivo guardado';

  @override
  String get savingsGoalContributionSaved => 'Contribución registrada';

  @override
  String get settingsDashSavingsGoals => 'Objetivos de Ahorro';

  @override
  String get savingsGoalActive => 'Activo';

  @override
  String get savingsGoalInactive => 'Inactivo';

  @override
  String savingsGoalDaysLeft(String days) {
    return '$days días restantes';
  }

  @override
  String get savingsGoalOverdue => 'Vencido';

  @override
  String get mealCostReconciliation => 'Costes de Comidas';

  @override
  String get mealCostEstimated => 'Estimado';

  @override
  String get mealCostActual => 'Real';

  @override
  String mealCostWeek(String number) {
    return 'Semana $number';
  }

  @override
  String get mealCostTotal => 'Total del Mes';

  @override
  String get mealCostSavings => 'Ahorro';

  @override
  String get mealCostOverrun => 'Exceso';

  @override
  String get mealCostNoData => 'Sin datos de compras para comidas.';

  @override
  String get mealCostViewCosts => 'Costes';

  @override
  String get mealCostIsMealPurchase => 'Compra para comidas';

  @override
  String get mealCostVsBudget => 'vs presupuesto';

  @override
  String get mealCostOnTrack => 'Dentro del presupuesto';

  @override
  String get mealCostOver => 'Por encima del presupuesto';

  @override
  String get mealCostUnder => 'Por debajo del presupuesto';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettings => 'Ajustes de Notificaciones';

  @override
  String get notificationBillReminders => 'Recordatorios de facturas';

  @override
  String get notificationBillReminderDays => 'Días antes del vencimiento';

  @override
  String get notificationBudgetAlerts => 'Alertas de presupuesto';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'Límite de alerta ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Recordatorio de plan de comidas';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifica si no hay plan para el mes actual';

  @override
  String get notificationCustomReminders => 'Recordatorios Personalizados';

  @override
  String get notificationAddCustom => 'Añadir Recordatorio';

  @override
  String get notificationCustomTitle => 'Título';

  @override
  String get notificationCustomBody => 'Mensaje';

  @override
  String get notificationCustomTime => 'Hora';

  @override
  String get notificationCustomRepeat => 'Repetir';

  @override
  String get notificationCustomRepeatDaily => 'Diario';

  @override
  String get notificationCustomRepeatWeekly => 'Semanal';

  @override
  String get notificationCustomRepeatMonthly => 'Mensual';

  @override
  String get notificationCustomRepeatNone => 'No repetir';

  @override
  String get notificationCustomSaved => 'Recordatorio guardado';

  @override
  String get notificationCustomDeleteConfirm => '¿Eliminar este recordatorio?';

  @override
  String get notificationEmpty => 'Sin recordatorios personalizados.';

  @override
  String notificationBillTitle(String name) {
    return 'Factura pendiente: $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount vence en $days días';
  }

  @override
  String get notificationBudgetTitle => 'Alerta de presupuesto';

  @override
  String notificationBudgetBody(String percent) {
    return 'Ya has gastado el $percent% del presupuesto mensual';
  }

  @override
  String get notificationMealPlanTitle => 'Plan de comidas';

  @override
  String get notificationMealPlanBody =>
      'Aún no has generado el plan de comidas de este mes';

  @override
  String get notificationPermissionRequired =>
      'Permiso de notificaciones requerido';

  @override
  String get notificationSelectDays => 'Seleccionar días';

  @override
  String get settingsColorPalette => 'Paleta de colores';

  @override
  String get paletteOcean => 'Océano';

  @override
  String get paletteEmerald => 'Esmeralda';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteTeal => 'Verde azulado';

  @override
  String get paletteSunset => 'Atardecer';

  @override
  String get exportTooltip => 'Exportar';

  @override
  String get exportTitle => 'Exportar mes';

  @override
  String get exportPdf => 'Informe PDF';

  @override
  String get exportPdfDesc => 'Informe con presupuesto vs real';

  @override
  String get exportCsv => 'Datos CSV';

  @override
  String get exportCsvDesc => 'Datos para hoja de cálculo';

  @override
  String get exportReportTitle => 'Informe Mensual de Gastos';

  @override
  String get exportBudgetVsActual => 'Presupuesto vs Real';

  @override
  String get exportExpenseDetail => 'Detalle de Gastos';

  @override
  String get searchExpenses => 'Buscar';

  @override
  String get searchExpensesHint => 'Buscar por descripción...';

  @override
  String get searchDateRange => 'Período';

  @override
  String get searchNoResults => 'No se encontraron gastos';

  @override
  String searchResultCount(int count) {
    return '$count resultados';
  }

  @override
  String get expenseFixed => 'Fijo';

  @override
  String get expenseVariable => 'Variable';

  @override
  String monthlyBudgetHint(String month) {
    return 'Presupuesto para $month';
  }

  @override
  String unsetBudgetsWarning(int count) {
    return '$count presupuestos variables sin definir';
  }

  @override
  String get unsetBudgetsCta => 'Definir en ajustes';

  @override
  String paceProjected(String amount) {
    return 'Proyección: $amount';
  }

  @override
  String get onbSkip => 'Saltar';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get onbGetStarted => 'Empezar';

  @override
  String get onbSlide0Title => 'Tu presupuesto, de un vistazo';

  @override
  String get onbSlide0Body =>
      'El panel muestra tu liquidez mensual, gastos e Índice de Serenidad.';

  @override
  String get onbSlide1Title => 'Registra cada gasto';

  @override
  String get onbSlide1Body =>
      'Toca + para registrar una compra. Asigna una categoría y observa las barras actualizarse.';

  @override
  String get onbSlide2Title => 'Compra con lista';

  @override
  String get onbSlide2Body =>
      'Explora productos, crea una lista y finaliza para registrar el gasto automáticamente.';

  @override
  String get onbSlide3Title => 'Tu coach financiero IA';

  @override
  String get onbSlide3Body =>
      'Obtén un análisis en 3 partes basado en tu presupuesto real — no consejos genéricos.';

  @override
  String get onbSlide4Title => 'Planifica comidas en presupuesto';

  @override
  String get onbSlide4Body =>
      'Genera un plan mensual ajustado a tu presupuesto alimentario y tamaño del hogar.';

  @override
  String get onbTourSkip => 'Saltar tour';

  @override
  String get onbTourNext => 'Siguiente';

  @override
  String get onbTourDone => 'Entendido';

  @override
  String get onbTourDash1Title => 'Liquidez mensual';

  @override
  String get onbTourDash1Body =>
      'Ingresos menos todos los gastos. Verde significa saldo positivo.';

  @override
  String get onbTourDash2Title => 'Índice de Serenidad';

  @override
  String get onbTourDash2Body =>
      'Puntuación de salud financiera 0–100. Toca para ver los factores.';

  @override
  String get onbTourDash3Title => 'Presupuesto vs real';

  @override
  String get onbTourDash3Body => 'Gastos planificados vs reales por categoría.';

  @override
  String get onbTourDash4Title => 'Añadir gasto';

  @override
  String get onbTourDash4Body =>
      'Toca + en cualquier momento para registrar un gasto.';

  @override
  String get onbTourDash5Title => 'Navegación';

  @override
  String get onbTourDash5Body =>
      '5 secciones: Presupuesto, Supermercado, Lista, Coach, Comidas.';

  @override
  String get onbTourGrocery1Title => 'Buscar y filtrar';

  @override
  String get onbTourGrocery1Body => 'Busca por nombre o filtra por categoría.';

  @override
  String get onbTourGrocery2Title => 'Añadir a la lista';

  @override
  String get onbTourGrocery2Body =>
      'Toca + en cualquier producto para añadirlo a tu lista de compras.';

  @override
  String get onbTourGrocery3Title => 'Categorías';

  @override
  String get onbTourGrocery3Body =>
      'Desplaza los filtros de categoría para acotar productos.';

  @override
  String get onbTourShopping1Title => 'Marcar ítems';

  @override
  String get onbTourShopping1Body =>
      'Toca un ítem para marcarlo como recogido.';

  @override
  String get onbTourShopping2Title => 'Finalizar compra';

  @override
  String get onbTourShopping2Body =>
      'Registra el gasto y limpia los ítems marcados.';

  @override
  String get onbTourShopping3Title => 'Historial de compras';

  @override
  String get onbTourShopping3Body =>
      'Consulta todas las sesiones de compras anteriores aquí.';

  @override
  String get onbTourCoach1Title => 'Analizar mi presupuesto';

  @override
  String get onbTourCoach1Body =>
      'Toca para generar un análisis basado en tus datos reales.';

  @override
  String get onbTourCoach2Title => 'Historial de análisis';

  @override
  String get onbTourCoach2Body =>
      'Los análisis guardados aparecen aquí, más recientes primero.';

  @override
  String get onbTourMeals1Title => 'Generar plan';

  @override
  String get onbTourMeals1Body =>
      'Crea un mes completo de comidas dentro del presupuesto alimentario.';

  @override
  String get onbTourMeals2Title => 'Vista semanal';

  @override
  String get onbTourMeals2Body =>
      'Navega comidas por semana. Toca un día para ver la receta.';

  @override
  String get onbTourMeals3Title => 'Añadir a la lista de compras';

  @override
  String get onbTourMeals3Body =>
      'Envía los ingredientes de la semana a tu lista con un toque.';

  @override
  String get taxDeductionTitle => 'Deducciones Fiscales';

  @override
  String get taxDeductionSeeDetail => 'Ver detalle';

  @override
  String get taxDeductionEstimated => 'deducción estimada';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'Máx. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'Deducciones Fiscales — Detalle';

  @override
  String get taxDeductionDeductibleTitle => 'CATEGORÍAS DEDUCIBLES';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATEGORÍAS NO DEDUCIBLES';

  @override
  String get taxDeductionTotalLabel => 'DEDUCCIÓN ESTIMADA';

  @override
  String taxDeductionSpent(String amount) {
    return 'Gastado: $amount';
  }

  @override
  String taxDeductionCapUsed(String percent, String cap) {
    return '$percent de $cap utilizado';
  }

  @override
  String get taxDeductionNotDeductible => 'No deducible';

  @override
  String get taxDeductionDisclaimer =>
      'Estos valores son estimaciones basadas en los gastos registrados. Las deducciones reales dependen de las facturas registradas. Consulte a un profesional fiscal para importes definitivos.';

  @override
  String get settingsDashTaxDeductions => 'Deducciones fiscales (PT)';

  @override
  String get settingsDashUpcomingBills => 'Facturas pendientes';

  @override
  String get settingsDashBudgetStreaks => 'Rachas de presupuesto';

  @override
  String get upcomingBillsTitle => 'Facturas Pendientes';

  @override
  String get upcomingBillsManage => 'Gestionar';

  @override
  String get billDueToday => 'Hoy';

  @override
  String get billDueTomorrow => 'Mañana';

  @override
  String billDueInDays(int days) {
    return 'En $days días';
  }

  @override
  String savingsProjectionReachedBy(String date) {
    return 'Alcanzado para $date';
  }

  @override
  String savingsProjectionNeedPerMonth(String amount) {
    return 'Necesita $amount/mes para cumplir plazo';
  }

  @override
  String get savingsProjectionOnTrack => 'En camino';

  @override
  String get savingsProjectionBehind => 'Retrasado';

  @override
  String get savingsProjectionNoData =>
      'Añade contribuciones para ver proyección';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'Media $amount/mes';
  }

  @override
  String get taxSimTitle => 'Simulador Fiscal';

  @override
  String get taxSimPresets => 'ESCENARIOS RÁPIDOS';

  @override
  String get taxSimPresetRaise => '+€200 aumento';

  @override
  String get taxSimPresetMeal => 'Tarjeta vs efectivo';

  @override
  String get taxSimPresetTitular => 'Conjunto vs separado';

  @override
  String get taxSimParameters => 'PARÁMETROS';

  @override
  String get taxSimGross => 'Salario bruto';

  @override
  String get taxSimMarital => 'Estado civil';

  @override
  String get taxSimTitulares => 'Titulares';

  @override
  String get taxSimDependentes => 'Dependientes';

  @override
  String get taxSimMealType => 'Tipo de subsidio de comida';

  @override
  String get taxSimMealAmount => 'Subsidio comida/día';

  @override
  String get taxSimComparison => 'ACTUAL VS SIMULADO';

  @override
  String get taxSimNetTakeHome => 'Neto a recibir';

  @override
  String get taxSimIRS => 'Retención IRPF';

  @override
  String get taxSimSS => 'Seguridad social';

  @override
  String get taxSimDelta => 'Diferencia mensual:';

  @override
  String get taxSimButton => 'Simulador Fiscal';

  @override
  String get streakTitle => 'Rachas de Presupuesto';

  @override
  String get streakBronze => 'Bronce';

  @override
  String get streakSilver => 'Plata';

  @override
  String get streakGold => 'Oro';

  @override
  String get streakBronzeDesc => 'Liquidez positiva';

  @override
  String get streakSilverDesc => 'Dentro del presupuesto';

  @override
  String get streakGoldDesc => 'Todas las categorías';

  @override
  String streakMonths(int count) {
    return '$count meses';
  }
}
