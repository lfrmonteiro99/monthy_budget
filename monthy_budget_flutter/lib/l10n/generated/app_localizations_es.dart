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
  String get navGroceryTooltip => 'CatÃ¡logo de productos';

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
  String get loadingApp => 'Cargando la aplicaciÃ³n';

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
    return 'AÃ±adir $name a la lista';
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
  String get enumCatEnergia => 'EnergÃ­a';

  @override
  String get enumCatAgua => 'Agua';

  @override
  String get enumCatAlimentacao => 'AlimentaciÃ³n';

  @override
  String get enumCatEducacao => 'EducaciÃ³n';

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
  String get enumChartExpensesPie => 'Gastos por CategorÃ­a';

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
  String get enumObjHighProtein => 'Alta proteÃ­na';

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
  String get enumEquipPressureCooker => 'Olla a presiÃ³n';

  @override
  String get enumEquipMicrowave => 'Microondas';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'Sin restricciÃ³n';

  @override
  String get enumSodiumReduced => 'Sodio reducido';

  @override
  String get enumSodiumLow => 'Bajo en sodio';

  @override
  String get enumAge0to3 => '0â€“3 aÃ±os';

  @override
  String get enumAge4to10 => '4â€“10 aÃ±os';

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
  String get enumMedHypertension => 'HipertensiÃ³n';

  @override
  String get enumMedHighCholesterol => 'Colesterol alto';

  @override
  String get enumMedGout => 'Gota';

  @override
  String get enumMedIbs => 'SÃ­ndrome del intestino irritable';

  @override
  String get stressExcellent => 'Excelente';

  @override
  String get stressGood => 'Bueno';

  @override
  String get stressWarning => 'AtenciÃ³n';

  @override
  String get stressCritical => 'CrÃ­tico';

  @override
  String get stressFactorSavings => 'Tasa de ahorro';

  @override
  String get stressFactorSafety => 'Margen de seguridad';

  @override
  String get stressFactorFood => 'Presupuesto alimentaciÃ³n';

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
    return 'La alimentaciÃ³n superÃ³ el presupuesto en $percent% â€” considere revisar porciones o frecuencia de compras.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Los gastos reales superaron lo planificado en $amountâ‚¬ â€” Â¿ajustar valores en configuraciÃ³n?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'AhorrÃ³ $amountâ‚¬ mÃ¡s de lo previsto â€” puede reforzar el fondo de emergencia.';
  }

  @override
  String get monthReviewOnTrack =>
      'Gastos dentro de lo previsto. Buen control presupuestario.';

  @override
  String get dashboardTitle => 'Presupuesto Mensual';

  @override
  String get dashboardStressIndex => 'Ãndice de Tranquilidad';

  @override
  String get dashboardTension => 'TensiÃ³n';

  @override
  String get dashboardLiquidity => 'Liquidez';

  @override
  String get dashboardFinalPosition => 'PosiciÃ³n Final';

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
  String get dashboardViewTrends => 'Ver evoluciÃ³n';

  @override
  String get dashboardViewProjection => 'Ver proyecciÃ³n';

  @override
  String get dashboardFinancialSummary => 'RESUMEN FINANCIERO';

  @override
  String get dashboardOpenSettings => 'Abrir configuraciÃ³n';

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
  String get dashboardOpenSettingsButton => 'Abrir ConfiguraciÃ³n';

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
  String get dashboardFood => 'ALIMENTACIÃ“N';

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
  String get dashboardPaceWarning => 'Gastando mÃ¡s rÃ¡pido de lo previsto';

  @override
  String get dashboardPaceCritical =>
      'Riesgo de superar presupuesto alimentario';

  @override
  String get dashboardPace => 'Ritmo';

  @override
  String get dashboardProjection => 'ProyecciÃ³n';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actual€/dÃ­a vs $expected€/dÃ­a';
  }

  @override
  String get dashboardSummaryLabel => 'â€” RESUMEN';

  @override
  String get dashboardViewMonthSummary => 'Ver resumen del mes';

  @override
  String get coachTitle => 'Coach Financiero';

  @override
  String get coachSubtitle => 'IA Â· GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'AÃ±ade tu API key de OpenAI en ConfiguraciÃ³n para usar esta funcionalidad.';

  @override
  String get coachAnalysisTitle => 'AnÃ¡lisis financiero en 3 partes';

  @override
  String get coachAnalysisDescription =>
      'Posicionamiento general Â· Factores crÃ­ticos del Ãndice de Tranquilidad Â· Oportunidad inmediata. Basado en tus datos reales de presupuesto, gastos e historial de compras.';

  @override
  String get coachConfigureApiKey => 'Configurar API key en Ajustes';

  @override
  String get coachApiKeyConfigured => 'API key configurada';

  @override
  String get coachAnalyzeButton => 'Analizar mi presupuesto';

  @override
  String get coachAnalyzing => 'Analizando...';

  @override
  String get coachCustomAnalysis => 'AnÃ¡lisis personalizado';

  @override
  String get coachNewAnalysis => 'Generar nuevo anÃ¡lisis';

  @override
  String get coachHistory => 'HISTORIAL';

  @override
  String get coachClearAll => 'Limpiar todo';

  @override
  String get coachClearTitle => 'Limpiar historial';

  @override
  String get coachClearContent =>
      'Â¿EstÃ¡s seguro de que quieres eliminar todos los anÃ¡lisis guardados?';

  @override
  String get coachDeleteLabel => 'Eliminar anÃ¡lisis';

  @override
  String get coachDeleteTooltip => 'Eliminar';

  @override
  String get coachEmptyTitle => 'Tu coach financiero';

  @override
  String get coachEmptyBody =>
      'Pregunta lo que quieras sobre tu presupuesto, gastos o ahorros. Usare tus datos reales para darte consejos personalizados.';

  @override
  String get coachQuickPrompt1 => 'Donde puedo recortar gastos este mes?';

  @override
  String get coachQuickPrompt2 => 'Como puedo mejorar mi ahorro?';

  @override
  String get coachQuickPrompt3 => 'Ayudame a crear un plan de 30 dias.';

  @override
  String get coachComposerHint => 'Pregunta a tu coach...';

  @override
  String get coachYou => 'Tu';

  @override
  String get coachAssistant => 'Coach';

  @override
  String coachCreditsCount(int count) {
    return '$count creditos';
  }

  @override
  String get coachMemory => 'Memoria';

  @override
  String get coachCostFree => 'Modo Eco — sin coste de creditos.';

  @override
  String coachCostCredits(int cost) {
    return 'Este mensaje cuesta $cost creditos.';
  }

  @override
  String get coachFree => 'Gratis';

  @override
  String coachPerMsg(int cost) {
    return '$cost/msg';
  }

  @override
  String get coachEcoFallbackTitle => 'Modo Eco activo (sin creditos)';

  @override
  String get coachEcoFallbackBody =>
      'Puedes seguir chateando con memoria reducida.';

  @override
  String get coachRestoreMemory => 'Restaurar memoria';

  @override
  String get cmdAssistantTitle => 'Asistente';

  @override
  String get cmdAssistantHint => 'Que necesitas?';

  @override
  String get cmdAssistantTooltip => 'Necesitas ayuda? Toca aqui';

  @override
  String get cmdSuggestionAddExpense => 'Anadir gasto';

  @override
  String get cmdSuggestionOpenList => 'Abrir lista de compras';

  @override
  String get cmdSuggestionChangeTheme => 'Cambiar tema';

  @override
  String get cmdSuggestionOpenSettings => 'Ir a ajustes';

  @override
  String get cmdTemplateAddExpense => 'Anade [cantidad] euros en [categoria]';

  @override
  String get cmdTemplateChangeTheme => 'Cambia el tema a [claro/oscuro]';

  @override
  String get cmdExecutionFailed =>
      'Entendi el pedido, pero no pude ejecutarlo. Intenta de nuevo.';

  @override
  String get cmdNotUnderstood => 'No entendi. Puedes reformular?';

  @override
  String get cmdUndo => 'Deshacer';

  @override
  String get expenseDeleted => 'Gasto eliminado';

  @override
  String get cmdCapabilitiesCta => 'Que puedo hacer?';

  @override
  String get cmdCapabilitiesTitle => 'Acciones disponibles';

  @override
  String get cmdCapabilitiesSubtitle =>
      'Estas son las acciones que el asistente soporta ahora mismo.';

  @override
  String get cmdCapabilitiesFooter =>
      'Seguimos anadiendo mas. Si no aparece aqui, puede que aun no funcione.';

  @override
  String get cmdCapabilityAddExpense => 'Anadir un gasto';

  @override
  String get cmdCapabilityAddExpenseExample =>
      'Anade [cantidad] euros en [categoria]';

  @override
  String get cmdCapabilityAddShoppingItem => 'Anadir a la lista';

  @override
  String get cmdCapabilityAddShoppingItemExample =>
      'Anade [articulo] a la lista de compras';

  @override
  String get cmdCapabilityRemoveShoppingItem => 'Quitar de la lista';

  @override
  String get cmdCapabilityRemoveShoppingItemExample =>
      'Quita [articulo] de la lista de compras';

  @override
  String get cmdCapabilityToggleShoppingItemChecked =>
      'Marcar o desmarcar de la lista';

  @override
  String get cmdCapabilityToggleShoppingItemCheckedExample =>
      'Marca [articulo] en la lista de compras';

  @override
  String get cmdCapabilityAddSavingsGoal => 'Crear objetivo de ahorro';

  @override
  String get cmdCapabilityAddSavingsGoalExample =>
      'Crea objetivo de ahorro [nombre] de [cantidad]';

  @override
  String get cmdCapabilityAddSavingsContribution =>
      'Anadir al objetivo de ahorro';

  @override
  String get cmdCapabilityAddSavingsContributionExample =>
      'Anade [cantidad] al objetivo [nombre]';

  @override
  String get cmdCapabilityAddRecurringExpense => 'Anadir gasto recurrente';

  @override
  String get cmdCapabilityAddRecurringExpenseExample =>
      'Anade gasto recurrente [cantidad] en [categoria] dia [dia]';

  @override
  String get cmdCapabilityDeleteExpense => 'Eliminar un gasto';

  @override
  String get cmdCapabilityDeleteExpenseExample =>
      'Elimina el gasto [descripcion]';

  @override
  String get cmdCapabilityChangeTheme => 'Cambiar tema';

  @override
  String get cmdCapabilityChangeThemeExample =>
      'Cambia el tema a [claro/oscuro]';

  @override
  String get cmdCapabilityChangePalette => 'Cambiar paleta';

  @override
  String get cmdCapabilityChangePaletteExample =>
      'Color [ocean/emerald/violet/teal/sunset]';

  @override
  String get cmdCapabilityChangeLanguage => 'Cambiar idioma';

  @override
  String get cmdCapabilityChangeLanguageExample =>
      'Idioma [ingles/portugues/espanol/frances]';

  @override
  String get cmdCapabilityNavigate => 'Abrir pantalla';

  @override
  String get cmdCapabilityNavigateExample => 'Abrir lista de compras';

  @override
  String get cmdCapabilityClearChecked => 'Limpiar marcados';

  @override
  String get cmdCapabilityClearCheckedExample => 'Limpiar elementos marcados';

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
    return '$name aÃ±adido a la lista';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit Â· precio medio';
  }

  @override
  String get shoppingTitle => 'Lista de la Compra';

  @override
  String get shoppingEmpty => 'Lista vacÃ­a';

  @override
  String get shoppingEmptyMessage =>
      'AÃ±ade productos desde la\npantalla Supermercado.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count por comprar Â· $total';
  }

  @override
  String get shoppingClear => 'Limpiar';

  @override
  String get shoppingFinalize => 'Finalizar Compra';

  @override
  String get shoppingEstimatedTotal => 'Total estimado';

  @override
  String get shoppingHowMuchSpent => 'Â¿CUÃNTO GASTÃ‰ EN TOTAL? (opcional)';

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
  String get authLogin => 'Iniciar sesiÃ³n';

  @override
  String get authRegister => 'Crear cuenta';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'ejemplo@email.com';

  @override
  String get authPassword => 'ContraseÃ±a';

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
      'Â¡Cuenta creada! Revisa tu email para verificar la cuenta antes de iniciar sesiÃ³n.';

  @override
  String get authErrorNetwork =>
      'No se pudo conectar al servidor. Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get authErrorInvalidCredentials =>
      'Email o contraseña incorrectos. Inténtalo de nuevo.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Verifica tu email antes de iniciar sesión.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Espera un momento e inténtalo de nuevo.';

  @override
  String get authErrorGeneric =>
      'Algo salió mal. Inténtalo de nuevo más tarde.';

  @override
  String get householdSetupTitle => 'Configurar Hogar';

  @override
  String get householdCreate => 'Crear';

  @override
  String get householdJoinWithCode => 'Unirse con cÃ³digo';

  @override
  String get householdNameLabel => 'Nombre del hogar';

  @override
  String get householdNameHint => 'ej: Familia GarcÃ­a';

  @override
  String get householdCodeLabel => 'CÃ³digo de invitaciÃ³n';

  @override
  String get householdCodeHint => 'XXXXXX';

  @override
  String get householdCreateButton => 'Crear Hogar';

  @override
  String get householdJoinButton => 'Unirse al Hogar';

  @override
  String get householdNameRequired => 'Indica el nombre del hogar.';

  @override
  String get chartExpensesByCategory => 'Gastos por CategorÃ­a';

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
    return 'ProyecciÃ³n â€” $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'GastÃ³ $spent de $budget en $days dÃ­as';
  }

  @override
  String get projectionFood => 'ALIMENTACIÃ“N';

  @override
  String get projectionCurrentPace => 'Ritmo actual';

  @override
  String get projectionNoShopping => 'Sin compras';

  @override
  String get projectionReduce20 => '-20%';

  @override
  String projectionDailySpend(String amount) {
    return 'Gasto diario estimado: $amount/dÃ­a';
  }

  @override
  String get projectionEndOfMonth => 'ProyecciÃ³n fin de mes';

  @override
  String get projectionRemaining => 'Restante proyectado';

  @override
  String get projectionStressImpact => 'Impacto en el Ãndice';

  @override
  String get projectionExpenses => 'GASTOS';

  @override
  String get projectionSimulation => 'SimulaciÃ³n â€” no guardado';

  @override
  String get projectionReduceAll => 'Reducir todas en ';

  @override
  String get projectionSimLiquidity => 'Liquidez simulada';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Tasa ahorro simulada';

  @override
  String get projectionSimIndex => 'Ãndice simulado';

  @override
  String get trendTitle => 'EvoluciÃ³n';

  @override
  String get trendStressIndex => 'ÃNDICE DE TRANQUILIDAD';

  @override
  String get trendTotalExpenses => 'GASTOS TOTALES';

  @override
  String get trendExpensesByCategory => 'GASTOS POR CATEGORÃA';

  @override
  String trendCurrent(String amount) {
    return 'Actual: $amount';
  }

  @override
  String get trendCatTelecom => 'Telecom';

  @override
  String get trendCatEnergy => 'EnergÃ­a';

  @override
  String get trendCatWater => 'Agua';

  @override
  String get trendCatFood => 'AlimentaciÃ³n';

  @override
  String get trendCatEducation => 'EducaciÃ³n';

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
    return 'Resumen â€” $month';
  }

  @override
  String get monthReviewPlanned => 'Planificado';

  @override
  String get monthReviewActual => 'Real';

  @override
  String get monthReviewDifference => 'Diferencia';

  @override
  String get monthReviewFood => 'AlimentaciÃ³n';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual de $budget';
  }

  @override
  String get monthReviewTopDeviations => 'MAYORES DESVIACIONES';

  @override
  String get monthReviewSuggestions => 'SUGERENCIAS';

  @override
  String get monthReviewAiAnalysis => 'AnÃ¡lisis IA detallado';

  @override
  String get mealPlannerTitle => 'Planificador de Comidas';

  @override
  String get mealBudgetLabel => 'Presupuesto alimentaciÃ³n';

  @override
  String get mealPeopleLabel => 'Personas en el hogar';

  @override
  String get mealGeneratePlan => 'Generar Plan Mensual';

  @override
  String get mealGenerating => 'Generando...';

  @override
  String get mealRegenerateTitle => 'Â¿Regenerar plan?';

  @override
  String get mealRegenerateContent => 'El plan actual serÃ¡ sustituido.';

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
  String get mealAddWeekToList => 'AÃ±adir semana a la lista';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingredientes aÃ±adidos a la lista';
  }

  @override
  String mealDayLabel(int n) {
    return 'DÃ­a $n';
  }

  @override
  String get mealIngredients => 'Ingredientes';

  @override
  String get mealPreparation => 'PreparaciÃ³n';

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
    return '$costâ‚¬ total';
  }

  @override
  String get mealCatProteins => 'ProteÃ­nas';

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
      'Â¿QuÃ© comidas quieres incluir en el plan diario?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight del presupuesto';
  }

  @override
  String get wizardObjectiveQuestion =>
      'Â¿CuÃ¡l es el objetivo principal de tu plan alimentario?';

  @override
  String wizardSelected(String label) {
    return '$label, seleccionado';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRICCIONES DIETÃ‰TICAS';

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
  String get wizardDislikedHint => 'ej: atÃºn, brÃ³coli';

  @override
  String get wizardMaxPrepTime => 'TIEMPO MÃXIMO POR COMIDA';

  @override
  String get wizardMaxComplexity => 'COMPLEJIDAD MÃXIMA';

  @override
  String get wizardComplexityEasy => 'FÃ¡cil';

  @override
  String get wizardComplexityMedium => 'Medio';

  @override
  String get wizardComplexityAdvanced => 'Avanzado';

  @override
  String get wizardEquipment => 'EQUIPAMIENTO DISPONIBLE';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc => 'Cocinar para varios dÃ­as a la vez';

  @override
  String get wizardMaxBatchDays => 'MÃXIMO DE DÃAS POR RECETA';

  @override
  String wizardBatchDays(int days) {
    return '$days dÃ­as';
  }

  @override
  String get wizardPreferredCookingDay => 'DÃA PREFERIDO PARA COCINAR';

  @override
  String get wizardReuseLeftovers => 'Reutilizar sobras';

  @override
  String get wizardReuseLeftoversDesc =>
      'La cena de ayer = almuerzo de hoy (coste 0)';

  @override
  String get wizardMaxNewIngredients =>
      'MÃXIMO DE INGREDIENTES NUEVOS POR SEMANA';

  @override
  String get wizardNoLimit => 'Sin lÃ­mite';

  @override
  String get wizardMinimizeWaste => 'Minimizar desperdicio';

  @override
  String get wizardMinimizeWasteDesc =>
      'Preferir recetas que reutilicen ingredientes ya usados';

  @override
  String get wizardSettingsInfo =>
      'Puedes cambiar la configuraciÃ³n del planificador en cualquier momento en Ajustes â†’ Comidas.';

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
  String get wizardWeekdayWed => 'MiÃ©';

  @override
  String get wizardWeekdayThu => 'Jue';

  @override
  String get wizardWeekdayFri => 'Vie';

  @override
  String get wizardWeekdaySat => 'SÃ¡b';

  @override
  String get wizardWeekdaySun => 'Dom';

  @override
  String wizardPrepMin(int mins) {
    return '${mins}min';
  }

  @override
  String get wizardPrepMin60Plus => '60+';

  @override
  String get settingsTitle => 'ConfiguraciÃ³n';

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
  String get settingsRegion => 'RegiÃ³n e Idioma';

  @override
  String get settingsCountry => 'PaÃ­s';

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
  String get settingsMealAllowancePerDay => 'Importe/dÃ­a';

  @override
  String get settingsWorkingDays => 'DÃ­as laborables/mes';

  @override
  String get settingsOtherExemptIncome => 'Otros ingresos exentos';

  @override
  String get settingsAddSalary => 'AÃ±adir salario';

  @override
  String get settingsAddExpense => 'AÃ±adir categorÃ­a';

  @override
  String get settingsExpenseName => 'Nombre de categorÃ­a';

  @override
  String get settingsExpenseAmount => 'Importe';

  @override
  String get settingsExpenseCategory => 'CategorÃ­a';

  @override
  String get settingsApiKey => 'API Key OpenAI';

  @override
  String get settingsInviteCode => 'CÃ³digo de invitaciÃ³n';

  @override
  String get settingsCopyCode => 'Copiar';

  @override
  String get settingsCodeCopied => 'Â¡CÃ³digo copiado!';

  @override
  String get settingsAdminOnly =>
      'Solo el administrador puede editar la configuraciÃ³n.';

  @override
  String get settingsShowSummaryCards => 'Mostrar tarjetas resumen';

  @override
  String get settingsEnabledCharts => 'GrÃ¡ficos activos';

  @override
  String get settingsLogout => 'Cerrar sesiÃ³n';

  @override
  String get settingsLogoutConfirmTitle => 'Cerrar sesiÃ³n';

  @override
  String get settingsLogoutConfirmContent =>
      'Â¿EstÃ¡s seguro de que quieres cerrar sesiÃ³n?';

  @override
  String get settingsLogoutConfirmButton => 'Cerrar sesiÃ³n';

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
  String get settingsDependentsLabel => 'NÃšMERO DE DEPENDIENTES';

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
  String get settingsAmountPerDay => 'IMPORTE/DÃA';

  @override
  String get settingsDaysPerMonth => 'DÃAS/MES';

  @override
  String get settingsTitularesLabel => 'N. TITULARES';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Titular$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'AÃ±adir salario';

  @override
  String get settingsAddExpenseButton => 'AÃ±adir CategorÃ­a';

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
  String get settingsDashStressIndex => 'Ãndice de Tranquilidad';

  @override
  String get settingsDashSummaryCards => 'Tarjetas resumen';

  @override
  String get settingsDashSalaryBreakdown => 'Detalle por salario';

  @override
  String get settingsDashFood => 'AlimentaciÃ³n';

  @override
  String get settingsDashPurchaseHistory => 'Historial de compras';

  @override
  String get settingsDashExpensesBreakdown => 'Desglose de gastos';

  @override
  String get settingsDashMonthReview => 'RevisiÃ³n del mes';

  @override
  String get settingsDashCharts => 'GrÃ¡ficos';

  @override
  String get dashGroupOverview => 'RESUMEN';

  @override
  String get dashGroupFinancialDetail => 'DETALLE FINANCIERO';

  @override
  String get dashGroupHistory => 'HISTORIAL';

  @override
  String get dashGroupCharts => 'GRÃFICOS';

  @override
  String get settingsVisibleCharts => 'GRÃFICOS VISIBLES';

  @override
  String get settingsFavTip =>
      'Los productos favoritos influyen en el plan de comidas — las recetas con esos ingredientes tienen prioridad.';

  @override
  String get settingsMyFavorites => 'MIS FAVORITOS';

  @override
  String get settingsProductCatalog => 'CATÃLOGO DE PRODUCTOS';

  @override
  String get settingsSearchProduct => 'Buscar producto...';

  @override
  String get settingsLoadingProducts => 'Cargando productos...';

  @override
  String get settingsAddIngredient => 'AÃ±adir ingrediente';

  @override
  String get settingsIngredientName => 'Nombre del ingrediente';

  @override
  String get settingsAddButton => 'AÃ±adir';

  @override
  String get settingsAddToPantry => 'AÃ±adir a la despensa';

  @override
  String get settingsHouseholdPeople => 'HOGAR (PERSONAS)';

  @override
  String get settingsAutomatic => '(auto)';

  @override
  String get settingsUseAutoValue => 'Usar valor automÃ¡tico';

  @override
  String settingsManualValue(int count) {
    return 'Valor manual: $count personas';
  }

  @override
  String settingsAutoValue(int count) {
    return 'Calculado automÃ¡ticamente: $count (titulares + dependientes)';
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
  String get settingsAddMember => 'AÃ±adir miembro';

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
  String get settingsKcalPerDay => 'kcal/dÃ­a';

  @override
  String get settingsProteinHint => 'ej: 60';

  @override
  String get settingsGramsPerDay => 'g/dÃ­a';

  @override
  String get settingsFiberHint => 'ej: 25';

  @override
  String get settingsDailyProtein => 'ProteÃ­na diaria';

  @override
  String get settingsDailyFiber => 'Fibra diaria';

  @override
  String get settingsMedicalConditions => 'CONDICIONES MÃ‰DICAS';

  @override
  String get settingsActiveMeals => 'COMIDAS ACTIVAS';

  @override
  String get settingsObjective => 'OBJETIVO';

  @override
  String get settingsVeggieDays => 'DÃAS VEGETARIANOS POR SEMANA';

  @override
  String get settingsDietaryRestrictions => 'RESTRICCIONES DIETÃ‰TICAS';

  @override
  String get settingsEggFree => 'Sin huevos';

  @override
  String get settingsSodiumPref => 'PREFERENCIA DE SODIO';

  @override
  String get settingsDislikedIngredients => 'INGREDIENTES NO DESEADOS';

  @override
  String get settingsExcludedProteins => 'PROTEÃNAS EXCLUIDAS';

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
  String get settingsProteinTuna => 'AtÃºn';

  @override
  String get settingsProteinEgg => 'Huevos';

  @override
  String get settingsMaxPrepTime => 'TIEMPO MÃXIMO (MINUTOS)';

  @override
  String settingsMaxComplexity(int value) {
    return 'COMPLEJIDAD MÃXIMA ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'TIEMPO FIN DE SEMANA (MINUTOS)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'COMPLEJIDAD FIN DE SEMANA ($value/5)';
  }

  @override
  String get settingsEatingOutDays => 'DÃAS DE COMER FUERA';

  @override
  String get settingsWeeklyDistribution => 'DISTRIBUCIÃ“N SEMANAL';

  @override
  String settingsFishPerWeek(String count) {
    return 'Pescado por semana: $count';
  }

  @override
  String get settingsNoMinimum => 'sin mÃ­nimo';

  @override
  String settingsLegumePerWeek(String count) {
    return 'Legumbres por semana: $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Carne roja mÃ¡x/semana: $count';
  }

  @override
  String get settingsNoLimit => 'sin lÃ­mite';

  @override
  String get settingsAvailableEquipment => 'EQUIPAMIENTO DISPONIBLE';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'MÃXIMO DE DÃAS POR RECETA';

  @override
  String get settingsReuseLeftovers => 'Reutilizar sobras';

  @override
  String get settingsMinimizeWaste => 'Minimizar desperdicio';

  @override
  String get settingsPrioritizeLowCost => 'Priorizar bajo coste';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'Preferir recetas mÃ¡s econÃ³micas';

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
      'La clave se guarda localmente en el dispositivo y nunca se comparte. Usa el modelo GPT-4o mini (~€0,00008 por anÃ¡lisis).';

  @override
  String get settingsInviteCodeLabel => 'CÃ“DIGO DE INVITACIÃ“N';

  @override
  String get settingsGenerateInvite => 'Generar cÃ³digo de invitaciÃ³n';

  @override
  String get settingsShareWithMembers => 'Compartir con miembros del hogar';

  @override
  String get settingsNewCode => 'Nuevo cÃ³digo';

  @override
  String get settingsCodeValidInfo =>
      'El cÃ³digo es vÃ¡lido por 7 dÃ­as. CompÃ¡rtelo con quien quieras aÃ±adir al hogar.';

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
  String get countryES => 'EspaÃ±a';

  @override
  String get countryFR => 'Francia';

  @override
  String get countryUK => 'Reino Unido';

  @override
  String get langPT => 'PortuguÃªs';

  @override
  String get langEN => 'English';

  @override
  String get langFR => 'FranÃ§ais';

  @override
  String get langES => 'EspaÃ±ol';

  @override
  String get langSystem => 'Sistema';

  @override
  String get taxIncomeTax => 'Impuesto sobre la renta';

  @override
  String get taxSocialContribution => 'ContribuciÃ³n social';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'Seguridad Social';

  @override
  String get taxIRPF => 'IRPF';

  @override
  String get taxSSSpain => 'Seguridad Social';

  @override
  String get taxIR => 'ImpÃ´t sur le Revenu';

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
      'Eres un analista financiero personal para usuarios portugueses. Responde siempre en portuguÃ©s europeo. SÃ© directo y analÃ­tico â€” usa siempre nÃºmeros concretos del contexto proporcionado. Estructura la respuesta exactamente en las 3 partes pedidas. No introduzcas datos, benchmarks o referencias externas no proporcionados.';

  @override
  String get aiCoachInvalidApiKey =>
      'API key invÃ¡lida. Verifica en ConfiguraciÃ³n.';

  @override
  String get aiCoachMidMonthSystem =>
      'Eres un consultor de presupuesto domÃ©stico portuguÃ©s. Responde siempre en portuguÃ©s europeo. SÃ© prÃ¡ctico y directo.';

  @override
  String get aiMealPlannerSystem =>
      'Eres un chef portuguÃ©s. Responde siempre en portuguÃ©s europeo. Responde SOLO con JSON vÃ¡lido, sin texto adicional.';

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
      'Vamos a configurar lo esencial para que tu panel estÃ© listo.';

  @override
  String get setupWizardBullet1 => 'Calcular tu salario neto';

  @override
  String get setupWizardBullet2 => 'Organizar tus gastos';

  @override
  String get setupWizardBullet3 => 'Ver cuÃ¡nto te queda cada mes';

  @override
  String get setupWizardReassurance =>
      'Puedes cambiarlo todo mÃ¡s tarde en ajustes.';

  @override
  String get setupWizardStart => 'Empezar';

  @override
  String get setupWizardSkipAll => 'Saltar configuraciÃ³n';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get setupWizardContinue => 'Continuar';

  @override
  String get setupWizardCountryTitle => 'Â¿DÃ³nde vives?';

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
  String get setupWizardCountryES => 'EspaÃ±a';

  @override
  String get setupWizardCountryFR => 'Francia';

  @override
  String get setupWizardCountryUK => 'Reino Unido';

  @override
  String get setupWizardPersonalTitle => 'InformaciÃ³n personal';

  @override
  String get setupWizardPersonalSubtitle =>
      'Usamos esto para calcular tus impuestos con mÃ¡s precisiÃ³n.';

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
  String get setupWizardSalaryTitle => 'Â¿CuÃ¡l es tu salario?';

  @override
  String get setupWizardSalarySubtitle =>
      'Introduce el importe bruto mensual. Calculamos el neto automÃ¡ticamente.';

  @override
  String get setupWizardSalaryGross => 'Salario bruto mensual';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'Neto estimado: $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Puedes aÃ±adir mÃ¡s fuentes de ingreso mÃ¡s tarde.';

  @override
  String get setupWizardSalaryRequired => 'Por favor ingrese su salario';

  @override
  String get setupWizardSalaryPositive =>
      'El salario debe ser un número positivo';

  @override
  String get setupWizardSalarySkip => 'Saltar este paso';

  @override
  String get setupWizardExpensesTitle => 'Tus gastos mensuales';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valores sugeridos para tu paÃ­s. Ajusta segÃºn necesites.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Puedes aÃ±adir mÃ¡s categorÃ­as mÃ¡s tarde.';

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
  String get setupWizardCompleteTitle => 'Â¡Todo listo!';

  @override
  String get setupWizardCompleteReassurance =>
      'Tu presupuesto estÃ¡ configurado. Puedes ajustarlo todo en ajustes en cualquier momento.';

  @override
  String get setupWizardGoToDashboard => 'Ver mi presupuesto';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configura tu salario en ajustes para ver el cÃ¡lculo completo.';

  @override
  String get setupWizardExpRent => 'Alquiler / Hipoteca';

  @override
  String get setupWizardExpGroceries => 'AlimentaciÃ³n';

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
  String get expenseTrackerDeleteConfirm => 'Â¿Eliminar este gasto?';

  @override
  String get expenseTrackerEmpty =>
      'Sin gastos este mes.\nToca + para aÃ±adir el primero.';

  @override
  String get addExpenseTitle => 'AÃ±adir Gasto';

  @override
  String get editExpenseTitle => 'Editar Gasto';

  @override
  String get addExpenseCategory => 'CategorÃ­a';

  @override
  String get addExpenseAmount => 'Importe';

  @override
  String get addExpenseDate => 'Fecha';

  @override
  String get addExpenseDescription => 'DescripciÃ³n (opcional)';

  @override
  String get addExpenseCustomCategory => 'CategorÃ­a personalizada';

  @override
  String get addExpenseInvalidAmount => 'Introduce un importe vÃ¡lido';

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
  String get recurringExpenseAdd => 'AÃ±adir Factura';

  @override
  String get recurringExpenseEdit => 'Editar Factura';

  @override
  String get recurringExpenseCategory => 'CategorÃ­a';

  @override
  String get recurringExpenseAmount => 'Importe';

  @override
  String get recurringExpenseDescription => 'DescripciÃ³n (opcional)';

  @override
  String get recurringExpenseDayOfMonth => 'DÃ­a de vencimiento';

  @override
  String get recurringExpenseActive => 'Activo';

  @override
  String get recurringExpenseInactive => 'Inactivo';

  @override
  String get recurringExpenseEmpty =>
      'Sin facturas mensuales.\nAÃ±ade una para generarla automÃ¡ticamente cada mes.';

  @override
  String get recurringExpenseDeleteConfirm => 'Â¿Eliminar esta factura?';

  @override
  String get recurringExpenseAutoCreated => 'Creado automÃ¡ticamente';

  @override
  String get recurringExpenseManage => 'Gestionar facturas';

  @override
  String get recurringExpenseMarkRecurring => 'Marcar como factura mensual';

  @override
  String get recurringExpensePopulated =>
      'Facturas mensuales generadas para este mes';

  @override
  String get recurringExpenseDayHint => 'Ej: 1 para el dÃ­a 1';

  @override
  String get recurringExpenseNoDay => 'Sin dÃ­a fijo';

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
    return '$count facturas Â· $amount/mes';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Facturas ($amount) superan presupuesto';
  }

  @override
  String get billsAddBill => 'AÃ±adir Factura';

  @override
  String get billsBudgetSettings => 'ConfiguraciÃ³n del Presupuesto';

  @override
  String get billsRecurringBills => 'Facturas Recurrentes';

  @override
  String get billsDescription => 'DescripciÃ³n';

  @override
  String get billsAmount => 'Importe';

  @override
  String get billsDueDay => 'DÃ­a de vencimiento';

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
  String get expenseTrendsByCategory => 'Por CategorÃ­a';

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
  String get savingsGoalDeadline => 'Fecha lÃ­mite';

  @override
  String get savingsGoalNoDeadline => 'Sin fecha lÃ­mite';

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
  String get savingsGoalCompleted => 'Â¡Objetivo alcanzado!';

  @override
  String get savingsGoalEmpty =>
      'Sin objetivos de ahorro.\nCrea uno para seguir tu progreso.';

  @override
  String get savingsGoalDeleteConfirm => 'Â¿Eliminar este objetivo?';

  @override
  String get savingsGoalContribute => 'Contribuir';

  @override
  String get savingsGoalContributionAmount => 'Importe de contribuciÃ³n';

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
    return 'Tuviste $amount de excedente el mes pasado â€” Â¿quieres asignar a un objetivo?';
  }

  @override
  String get savingsGoalAllocate => 'Asignar';

  @override
  String get savingsGoalSaved => 'Objetivo guardado';

  @override
  String get savingsGoalContributionSaved => 'ContribuciÃ³n registrada';

  @override
  String get settingsDashSavingsGoals => 'Objetivos de Ahorro';

  @override
  String get savingsGoalActive => 'Activo';

  @override
  String get savingsGoalInactive => 'Inactivo';

  @override
  String savingsGoalDaysLeft(String days) {
    return '$days dÃ­as restantes';
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
  String get mealVariation => 'VariaciÃ³n';

  @override
  String get mealPairing => 'Maridaje';

  @override
  String get mealStorage => 'ConservaciÃ³n';

  @override
  String get mealLeftover => 'Sobras';

  @override
  String get mealLeftoverIdea => 'Idea de transformaciÃ³n';

  @override
  String get mealWeeklySummary => 'NutriciÃ³n Semanal';

  @override
  String get mealBatchPrepGuide => 'GuÃ­a de PreparaciÃ³n';

  @override
  String mealBatchTotalTime(String time) {
    return 'Tiempo estimado: $time';
  }

  @override
  String get mealBatchParallelTips => 'Consejos de cocina paralela';

  @override
  String get mealFeedbackLike => 'Me gusta';

  @override
  String get mealFeedbackDislike => 'No me gusta';

  @override
  String get mealFeedbackSkip => 'Saltar';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettings => 'Ajustes de Notificaciones';

  @override
  String get notificationBillReminders => 'Recordatorios de facturas';

  @override
  String get notificationBillReminderDays => 'DÃ­as antes del vencimiento';

  @override
  String get notificationBudgetAlerts => 'Alertas de presupuesto';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'LÃ­mite de alerta ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Recordatorio de plan de comidas';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifica si no hay plan para el mes actual';

  @override
  String get notificationCustomReminders => 'Recordatorios Personalizados';

  @override
  String get notificationAddCustom => 'AÃ±adir Recordatorio';

  @override
  String get notificationCustomTitle => 'TÃ­tulo';

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
  String get notificationCustomDeleteConfirm => 'Â¿Eliminar este recordatorio?';

  @override
  String get notificationEmpty => 'Sin recordatorios personalizados.';

  @override
  String notificationBillTitle(String name) {
    return 'Factura pendiente: $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount vence en $days dÃ­as';
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
      'AÃºn no has generado el plan de comidas de este mes';

  @override
  String get notificationPermissionRequired =>
      'Permiso de notificaciones requerido';

  @override
  String get notificationSelectDays => 'Seleccionar dÃ­as';

  @override
  String get settingsColorPalette => 'Paleta de colores';

  @override
  String get paletteOcean => 'OcÃ©ano';

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
  String get exportCsvDesc => 'Datos para hoja de cÃ¡lculo';

  @override
  String get exportReportTitle => 'Informe Mensual de Gastos';

  @override
  String get exportBudgetVsActual => 'Presupuesto vs Real';

  @override
  String get exportExpenseDetail => 'Detalle de Gastos';

  @override
  String get searchExpenses => 'Buscar';

  @override
  String get searchExpensesHint => 'Buscar por descripciÃ³n...';

  @override
  String get searchDateRange => 'PerÃ­odo';

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
    return 'ProyecciÃ³n: $amount';
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
      'El panel muestra tu liquidez mensual, gastos e Ãndice de Serenidad.';

  @override
  String get onbSlide1Title => 'Registra cada gasto';

  @override
  String get onbSlide1Body =>
      'Toca + para registrar una compra. Asigna una categorÃ­a y observa las barras actualizarse.';

  @override
  String get onbSlide2Title => 'Compra con lista';

  @override
  String get onbSlide2Body =>
      'Explora productos, crea una lista y finaliza para registrar el gasto automÃ¡ticamente.';

  @override
  String get onbSlide3Title => 'Tu coach financiero IA';

  @override
  String get onbSlide3Body =>
      'ObtÃ©n un anÃ¡lisis en 3 partes basado en tu presupuesto real — no consejos genÃ©ricos.';

  @override
  String get onbSlide4Title => 'Planifica comidas en presupuesto';

  @override
  String get onbSlide4Body =>
      'Genera un plan mensual ajustado a tu presupuesto alimentario y tamaÃ±o del hogar.';

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
  String get onbTourDash2Title => 'Ãndice de Serenidad';

  @override
  String get onbTourDash2Body =>
      'PuntuaciÃ³n de salud financiera 0–100. Toca para ver los factores.';

  @override
  String get onbTourDash3Title => 'Presupuesto vs real';

  @override
  String get onbTourDash3Body =>
      'Gastos planificados vs reales por categorÃ­a.';

  @override
  String get onbTourDash4Title => 'AÃ±adir gasto';

  @override
  String get onbTourDash4Body =>
      'Toca + en cualquier momento para registrar un gasto.';

  @override
  String get onbTourDash5Title => 'NavegaciÃ³n';

  @override
  String get onbTourDash5Body =>
      '5 secciones: Presupuesto, Supermercado, Lista, Coach, Comidas.';

  @override
  String get onbTourGrocery1Title => 'Buscar y filtrar';

  @override
  String get onbTourGrocery1Body => 'Busca por nombre o filtra por categorÃ­a.';

  @override
  String get onbTourGrocery2Title => 'AÃ±adir a la lista';

  @override
  String get onbTourGrocery2Body =>
      'Toca + en cualquier producto para aÃ±adirlo a tu lista de compras.';

  @override
  String get onbTourGrocery3Title => 'CategorÃ­as';

  @override
  String get onbTourGrocery3Body =>
      'Desplaza los filtros de categorÃ­a para acotar productos.';

  @override
  String get onbTourShopping1Title => 'Marcar Ã­tems';

  @override
  String get onbTourShopping1Body =>
      'Toca un Ã­tem para marcarlo como recogido.';

  @override
  String get onbTourShopping2Title => 'Finalizar compra';

  @override
  String get onbTourShopping2Body =>
      'Registra el gasto y limpia los Ã­tems marcados.';

  @override
  String get onbTourShopping3Title => 'Historial de compras';

  @override
  String get onbTourShopping3Body =>
      'Consulta todas las sesiones de compras anteriores aquÃ­.';

  @override
  String get onbTourCoach1Title => 'Analizar mi presupuesto';

  @override
  String get onbTourCoach1Body =>
      'Toca para generar un anÃ¡lisis basado en tus datos reales.';

  @override
  String get onbTourCoach2Title => 'Historial de anÃ¡lisis';

  @override
  String get onbTourCoach2Body =>
      'Los anÃ¡lisis guardados aparecen aquÃ­, mÃ¡s recientes primero.';

  @override
  String get onbTourMeals1Title => 'Generar plan';

  @override
  String get onbTourMeals1Body =>
      'Crea un mes completo de comidas dentro del presupuesto alimentario.';

  @override
  String get onbTourMeals2Title => 'Vista semanal';

  @override
  String get onbTourMeals2Body =>
      'Navega comidas por semana. Toca un dÃ­a para ver la receta.';

  @override
  String get onbTourMeals3Title => 'AÃ±adir a la lista de compras';

  @override
  String get onbTourMeals3Body =>
      'EnvÃ­a los ingredientes de la semana a tu lista con un toque.';

  @override
  String get onbTourExpenseTracker1Title => 'Navegación mensual';

  @override
  String get onbTourExpenseTracker1Body =>
      'Cambia entre meses para ver o añadir gastos de cualquier período.';

  @override
  String get onbTourExpenseTracker2Title => 'Resumen del presupuesto';

  @override
  String get onbTourExpenseTracker2Body =>
      'Ve tu presupuesto vs gasto real y el saldo restante de un vistazo.';

  @override
  String get onbTourExpenseTracker3Title => 'Por categoría';

  @override
  String get onbTourExpenseTracker3Body =>
      'Cada categoría muestra una barra de progreso. Toca para expandir y ver gastos individuales.';

  @override
  String get onbTourExpenseTracker4Title => 'Añadir gasto';

  @override
  String get onbTourExpenseTracker4Body =>
      'Toca + para registrar un nuevo gasto. Elige la categoría y el importe.';

  @override
  String get onbTourSavings1Title => 'Tus objetivos';

  @override
  String get onbTourSavings1Body =>
      'Cada tarjeta muestra el progreso hacia tu meta. Toca para ver detalles y añadir contribuciones.';

  @override
  String get onbTourSavings2Title => 'Crear objetivo';

  @override
  String get onbTourSavings2Body =>
      'Toca + para definir un nuevo objetivo de ahorro con importe meta y fecha límite opcional.';

  @override
  String get onbTourRecurring1Title => 'Gastos recurrentes';

  @override
  String get onbTourRecurring1Body =>
      'Facturas fijas mensuales como alquiler, suscripciones y servicios. Se incluyen automáticamente en tu presupuesto.';

  @override
  String get onbTourRecurring2Title => 'Añadir recurrente';

  @override
  String get onbTourRecurring2Body =>
      'Toca + para registrar un nuevo gasto recurrente con importe y día de vencimiento.';

  @override
  String get onbTourAssistant1Title => 'Asistente de comandos';

  @override
  String get onbTourAssistant1Body =>
      'Tu atajo para acciones rápidas. Toca para añadir gastos, cambiar ajustes, navegar y más u2014 solo escribe lo que necesitas.';

  @override
  String get taxDeductionTitle => 'Deducciones Fiscales';

  @override
  String get taxDeductionSeeDetail => 'Ver detalle';

  @override
  String get taxDeductionEstimated => 'deducciÃ³n estimada';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'MÃ¡x. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'Deducciones Fiscales â€” Detalle';

  @override
  String get taxDeductionDeductibleTitle => 'CATEGORÃAS DEDUCIBLES';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATEGORÃAS NO DEDUCIBLES';

  @override
  String get taxDeductionTotalLabel => 'DEDUCCIÃ“N ESTIMADA';

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
  String get billDueTomorrow => 'MaÃ±ana';

  @override
  String billDueInDays(int days) {
    return 'En $days dÃ­as';
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
      'AÃ±ade contribuciones para ver proyecciÃ³n';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'Media $amount/mes';
  }

  @override
  String get taxSimTitle => 'Simulador Fiscal';

  @override
  String get taxSimPresets => 'ESCENARIOS RÃPIDOS';

  @override
  String get taxSimPresetRaise => '+â‚¬200 aumento';

  @override
  String get taxSimPresetMeal => 'Tarjeta vs efectivo';

  @override
  String get taxSimPresetTitular => 'Conjunto vs separado';

  @override
  String get taxSimParameters => 'PARÃMETROS';

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
  String get taxSimMealAmount => 'Subsidio comida/dÃ­a';

  @override
  String get taxSimComparison => 'ACTUAL VS SIMULADO';

  @override
  String get taxSimNetTakeHome => 'Neto a recibir';

  @override
  String get taxSimIRS => 'RetenciÃ³n IRPF';

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
  String get streakGoldDesc => 'Todas las categorÃ­as';

  @override
  String streakMonths(int count) {
    return '$count meses';
  }

  @override
  String get expenseDefaultBudget => 'PRESUPUESTO BASE';

  @override
  String expenseOverrideActive(String month, String amount) {
    return 'Ajustado para $month: $amount';
  }

  @override
  String expenseAdjustMonth(String month) {
    return 'Ajustar para $month';
  }

  @override
  String get expenseAdjustMonthHint =>
      'Deje vacÃ­o para usar el presupuesto base';

  @override
  String get settingsPersonalTip =>
      'El estado civil y los dependientes afectan su tramo de IRPF, lo que determina cuÃ¡nto impuesto se retiene de su salario.';

  @override
  String get settingsSalariesTip =>
      'El salario bruto se usa para calcular el ingreso neto despuÃ©s de impuestos y seguridad social. AÃ±ada varios salarios si el hogar tiene mÃ¡s de un ingreso.';

  @override
  String get settingsExpensesTip =>
      'Defina el presupuesto mensual para cada categorÃ­a. Puede ajustarlo para meses especÃ­ficos en la vista de detalle.';

  @override
  String get settingsMealHouseholdTip =>
      'NÃºmero de personas que comen en casa. Esto ajusta recetas y porciones en el plan de comidas.';

  @override
  String get settingsHouseholdTip =>
      'Invite a familiares para compartir datos del presupuesto entre dispositivos. Todos los miembros ven los mismos gastos y presupuestos.';

  @override
  String get subscriptionTitle => 'SuscripciÃ³n';

  @override
  String get subscriptionFree => 'Gratuito';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get subscriptionFamily => 'Familia';

  @override
  String get subscriptionTrialActive => 'Prueba activa';

  @override
  String subscriptionTrialDaysLeft(int count) {
    return '$count dÃ­as restantes';
  }

  @override
  String get subscriptionTrialExpired => 'Prueba expirada';

  @override
  String get subscriptionUpgrade => 'Actualizar';

  @override
  String get subscriptionSeePlans => 'Ver Planes';

  @override
  String get subscriptionCurrentPlan => 'Plan Actual';

  @override
  String get subscriptionManage => 'Gestionar SuscripciÃ³n';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total funciones exploradas';
  }

  @override
  String get subscriptionTrialBannerTitle => 'Prueba Premium Activa';

  @override
  String subscriptionTrialEndingSoon(int count) {
    return 'Â¡$count dÃ­as restantes en tu prueba!';
  }

  @override
  String get subscriptionTrialLastDay =>
      'Â¡Ãšltimo dÃ­a de tu prueba gratuita!';

  @override
  String get subscriptionUpgradeNow => 'Actualizar Ahora';

  @override
  String get subscriptionKeepData => 'Mantener Tus Datos';

  @override
  String get subscriptionCancelAnytime => 'Cancela en cualquier momento';

  @override
  String get subscriptionNoHiddenFees => 'Sin cargos ocultos';

  @override
  String get subscriptionMostPopular => 'MÃ¡s Popular';

  @override
  String subscriptionYearlySave(int percent) {
    return 'ahorra $percent%';
  }

  @override
  String get subscriptionMonthly => 'Mensual';

  @override
  String get subscriptionYearly => 'Anual';

  @override
  String get subscriptionPerMonth => '/mes';

  @override
  String get subscriptionPerYear => '/aÃ±o';

  @override
  String get subscriptionBilledYearly => 'facturado anualmente';

  @override
  String get subscriptionStartPremium => 'Empezar Premium';

  @override
  String get subscriptionStartFamily => 'Empezar Familia';

  @override
  String get subscriptionContinueFree => 'Continuar Gratuito';

  @override
  String get subscriptionTrialEnded => 'Tu periodo de prueba ha terminado';

  @override
  String get subscriptionChoosePlan =>
      'Elige un plan para conservar todos tus datos y funciones';

  @override
  String get subscriptionUnlockPower =>
      'Desbloquea todo el poder de tu presupuesto';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature requiere una suscripciÃ³n de pago';
  }

  @override
  String subscriptionTryFeature(String feature) {
    return 'Prueba $feature';
  }

  @override
  String subscriptionExplore(String feature) {
    return 'Explorar $feature';
  }

  @override
  String get subtitleBatchCooking =>
      'Sugiere recetas que se pueden preparar con antelación para varias comidas';

  @override
  String get subtitleReuseLeftovers =>
      'Planifica comidas que reutilizan ingredientes de días anteriores';

  @override
  String get subtitleMinimizeWaste =>
      'Prioriza el uso de todos los ingredientes comprados antes de que caduquen';

  @override
  String get subtitleMealTypeInclude =>
      'Incluir esta comida en tu plan semanal';

  @override
  String get subtitleShowHeroCard =>
      'Tu resumen de liquidez neta en la parte superior';

  @override
  String get subtitleShowStressIndex =>
      'Puntuación (0-100) que mide la presión de gastos vs ingresos';

  @override
  String get subtitleShowMonthReview =>
      'Resumen comparativo de este mes con los anteriores';

  @override
  String get subtitleShowUpcomingBills =>
      'Gastos recurrentes en los próximos 30 días';

  @override
  String get subtitleShowSummaryCards =>
      'Ingresos, deducciones, gastos y tasa de ahorro';

  @override
  String get subtitleShowBudgetVsActual =>
      'Comparación lado a lado por categoría de gasto';

  @override
  String get subtitleShowExpensesBreakdown =>
      'Gráfico circular de gastos por categoría';

  @override
  String get subtitleShowSavingsGoals =>
      'Progreso hacia tus objetivos de ahorro';

  @override
  String get subtitleShowTaxDeductions =>
      'Deducciones fiscales elegibles estimadas este año';

  @override
  String get subtitleShowBudgetStreaks =>
      'Cuántos meses consecutivos te mantuviste dentro del presupuesto';

  @override
  String get subtitleShowPurchaseHistory =>
      'Compras recientes de la lista de compras y costes';

  @override
  String get subtitleShowCharts =>
      'Gráficos de tendencia de presupuesto, gastos e ingresos';

  @override
  String get subtitleChartExpensesPie => 'Distribución de gastos por categoría';

  @override
  String get subtitleChartIncomeVsExpenses =>
      'Ingresos mensuales comparados con el gasto total';

  @override
  String get subtitleChartDeductions =>
      'Desglose de gastos deducibles de impuestos';

  @override
  String get subtitleChartNetIncome =>
      'Tendencia del ingreso neto a lo largo del tiempo';

  @override
  String get subtitleChartSavingsRate =>
      'Porcentaje de ingresos ahorrados cada mes';

  @override
  String get helperCountry =>
      'Determina el sistema fiscal, la moneda y las tasas de seguridad social';

  @override
  String get helperLanguage =>
      'Sustituir el idioma del sistema. \"Sistema\" sigue la configuración del dispositivo';

  @override
  String get helperMaritalStatus =>
      'Afecta al cálculo del tramo fiscal del IRPF';

  @override
  String get helperMealObjective =>
      'Define el patrón alimentario: omnívoro, vegetariano, pescatariano, etc.';

  @override
  String get helperSodiumPreference =>
      'Filtra recetas por nivel de contenido de sodio';

  @override
  String subtitleDietaryRestriction(String ingredient) {
    return 'Excluye recetas que contienen $ingredient';
  }

  @override
  String subtitleExcludedProtein(String protein) {
    return 'Eliminar $protein de todas las sugerencias de comidas';
  }

  @override
  String subtitleKitchenEquipment(String equipment) {
    return 'Activa recetas que requieren $equipment';
  }

  @override
  String get helperVeggieDays =>
      'Número de días completamente vegetarianos por semana';

  @override
  String get helperFishDays => 'Recomendado: 2-3 veces por semana';

  @override
  String get helperLegumeDays => 'Recomendado: 2-3 veces por semana';

  @override
  String get helperRedMeatDays => 'Recomendado: máximo 2 veces por semana';

  @override
  String get helperMaxPrepTime =>
      'Tiempo máximo de cocción para comidas entre semana (minutos)';

  @override
  String get helperMaxComplexity =>
      'Nivel de dificultad de las recetas para días laborables';

  @override
  String get helperWeekendPrepTime =>
      'Tiempo máximo de cocción para comidas de fin de semana (minutos)';

  @override
  String get helperWeekendComplexity =>
      'Nivel de dificultad de las recetas para fines de semana';

  @override
  String get helperMaxBatchDays =>
      'Cuántos días se puede reutilizar una comida cocinada en lote';

  @override
  String get helperNewIngredients =>
      'Limita cuántos ingredientes nuevos aparecen cada semana';

  @override
  String get helperGrossSalary =>
      'Salario total antes de impuestos y deducciones';

  @override
  String get helperExemptIncome =>
      'Ingresos adicionales no sujetos a IRPF (ej.: subsidios)';

  @override
  String get helperMealAllowance => 'Subsidio de comida diario de tu empleador';

  @override
  String get helperWorkingDays =>
      'Típico: 22. Afecta al cálculo del subsidio de comida';

  @override
  String get helperSalaryLabel =>
      'Un nombre para identificar esta fuente de ingresos';

  @override
  String get helperExpenseAmount =>
      'Importe mensual presupuestado para esta categoría';

  @override
  String get helperCalorieTarget => 'Recomendado: 2000-2500 kcal para adultos';

  @override
  String get helperProteinTarget => 'Recomendado: 50-70g para adultos';

  @override
  String get helperFiberTarget => 'Recomendado: 25-30g para adultos';

  @override
  String get infoStressIndex =>
      'Compara el gasto real con tu presupuesto. Rangos de puntuación:\n\n0-30: Cómodo - gasto bien dentro del presupuesto\n30-60: Moderado - acercándose a los límites del presupuesto\n60-100: Crítico - el gasto excede significativamente el presupuesto';

  @override
  String get infoBudgetStreak =>
      'Meses consecutivos en los que tu gasto total se mantuvo dentro del presupuesto total.';

  @override
  String get infoUpcomingBills =>
      'Muestra gastos recurrentes en los próximos 30 días basándose en tus gastos mensuales.';

  @override
  String get infoSalaryBreakdown =>
      'Muestra cómo se divide tu salario bruto en impuesto IRPF, contribuciones a la seguridad social, ingreso neto y subsidio de comida.';

  @override
  String get infoBudgetVsActual =>
      'Compara lo que presupuestaste por categoría con lo que realmente gastaste. Verde significa por debajo del presupuesto, rojo significa por encima.';

  @override
  String get infoSavingsGoals =>
      'Progreso hacia cada objetivo de ahorro basado en las contribuciones realizadas.';

  @override
  String get infoTaxDeductions =>
      'Gastos deducibles estimados (salud, educación, vivienda). Son solo estimaciones - consulta a un profesional fiscal para valores precisos.';

  @override
  String get infoPurchaseHistory =>
      'Total gastado en compras de la lista de compras este mes.';

  @override
  String get infoExpensesBreakdown =>
      'Desglose visual de tus gastos por categoría del mes actual.';

  @override
  String get infoCharts =>
      'Datos de tendencia a lo largo del tiempo. Toca cualquier gráfico para una vista detallada.';

  @override
  String get infoExpenseTrackerSummary =>
      'Presupuestado = tu gasto mensual planificado. Real = lo que has gastado hasta ahora. Restante = presupuesto menos real.';

  @override
  String get infoExpenseTrackerProgress =>
      'Verde: por debajo del 75% del presupuesto. Amarillo: 75-100%. Rojo: por encima del presupuesto.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filtra gastos por texto, categoría o rango de fechas.';

  @override
  String get infoSavingsProjection =>
      'Basado en tus contribuciones mensuales medias. \"En camino\" significa que tu ritmo actual alcanza el objetivo a tiempo. \"Retrasado\" significa que necesitas aumentar las contribuciones.';

  @override
  String get infoSavingsRequired =>
      'La cantidad que necesitas ahorrar cada mes a partir de ahora para alcanzar tu objetivo en el plazo.';

  @override
  String get infoCoachModes =>
      'Eco: gratuito, sin memoria de conversación.\nPlus: 1 crédito por mensaje, recuerda los últimos 5 mensajes.\nPro: 2 créditos por mensaje, memoria de conversación completa.';

  @override
  String get infoCoachCredits =>
      'Los créditos se usan en los modos Plus y Pro. Recibes créditos iniciales al registrarte. El modo Eco es siempre gratuito.';

  @override
  String get helperWizardGrossSalary =>
      'Tu salario mensual total antes de impuestos';

  @override
  String get helperWizardMealAllowance =>
      'Subsidio de comida diario del empleador (si corresponde)';

  @override
  String get helperWizardRent => 'Pago mensual de vivienda';

  @override
  String get helperWizardGroceries =>
      'Presupuesto mensual de alimentación y productos del hogar';

  @override
  String get helperWizardTransport =>
      'Costes mensuales de transporte (combustible, transporte público, etc.)';

  @override
  String get helperWizardUtilities => 'Electricidad, agua y gas mensuales';

  @override
  String get helperWizardTelecom => 'Internet, teléfono y TV mensuales';

  @override
  String get savingsGoalHowItWorksTitle => '¿Cómo funciona?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Crea un objetivo con un nombre y el monto que quieres ahorrar (ej: \"Vacaciones — 2 000 €\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Opcionalmente define una fecha límite como referencia.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Cada vez que ahorres dinero, toca el objetivo y registra una contribución con el monto y la fecha.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Sigue tu progreso: la barra muestra cuánto has ahorrado y la proyección estima cuándo alcanzarás tu objetivo.';

  @override
  String get savingsGoalDashboardHint =>
      'Toca un objetivo para ver detalles y registrar contribuciones.';

  @override
  String get rateLimitMessage =>
      'Por favor, espera un momento antes de intentarlo de nuevo';

  @override
  String get householdActivityTitle => 'Actividad del Hogar';

  @override
  String get householdActivityFilterAll => 'Todo';

  @override
  String get householdActivityFilterShopping => 'Compras';

  @override
  String get householdActivityFilterMeals => 'Comidas';

  @override
  String get householdActivityFilterExpenses => 'Gastos';

  @override
  String get householdActivityFilterPantry => 'Despensa';

  @override
  String get householdActivityFilterSettings => 'Ajustes';

  @override
  String get householdActivityEmpty => 'Sin actividad';

  @override
  String get householdActivityEmptyMessage =>
      'Las acciones compartidas de tu hogar aparecerán aquí.';

  @override
  String get householdActivityToday => 'HOY';

  @override
  String get householdActivityYesterday => 'AYER';

  @override
  String get householdActivityThisWeek => 'ESTA SEMANA';

  @override
  String get householdActivityOlder => 'ANTERIORES';

  @override
  String get householdActivityJustNow => 'Ahora mismo';

  @override
  String householdActivityMinutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String householdActivityHoursAgo(int count) {
    return 'hace ${count}h';
  }

  @override
  String householdActivityDaysAgo(int count) {
    return 'hace ${count}d';
  }

  @override
  String householdActivityAddedBy(String name) {
    return 'Añadido por $name';
  }

  @override
  String householdActivityRemovedBy(String name) {
    return 'Eliminado por $name';
  }

  @override
  String householdActivitySwappedBy(String name) {
    return 'Cambiado por $name';
  }

  @override
  String householdActivityUpdatedBy(String name) {
    return 'Actualizado por $name';
  }

  @override
  String householdActivityCheckedBy(String name) {
    return 'Marcado por $name';
  }
}
