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
  String get enumAge0to3 => '0Ã¢â‚¬â€œ3 aÃ±os';

  @override
  String get enumAge4to10 => '4Ã¢â‚¬â€œ10 aÃ±os';

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
    return 'La alimentaciÃ³n superÃ³ el presupuesto en $percent% Ã¢â‚¬â€ considere revisar porciones o frecuencia de compras.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Los gastos reales superaron lo planificado en $amountÃ¢â€šÂ¬ Ã¢â‚¬â€ Â¿ajustar valores en configuraciÃ³n?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'AhorrÃ³ $amountÃ¢â€šÂ¬ mÃ¡s de lo previsto Ã¢â‚¬â€ puede reforzar el fondo de emergencia.';
  }

  @override
  String get monthReviewOnTrack =>
      'Gastos dentro de lo previsto. Buen control presupuestario.';

  @override
  String get dashboardTitle => 'Presupuesto Mensual';

  @override
  String get dashboardViewFullReport => 'Ver Informe Completo';

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
    return '$actualâ‚¬/dÃ­a vs $expectedâ‚¬/dÃ­a';
  }

  @override
  String get dashboardSummaryLabel => 'Ã¢â‚¬â€ RESUMEN';

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
  String get coachCostFree => 'Modo Eco â€” sin coste de creditos.';

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
  String get groceryAvailabilityTitle => 'Disponibilidad de datos';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Mercado: $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh frescas Â· $partial parciales Â· $failed no disponibles';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Algunas tiendas tienen datos parciales o desactualizados. Las comparaciones pueden estar incompletas.';

  @override
  String get groceryEmptyStateTitle =>
      'No hay datos de supermercado disponibles';

  @override
  String get groceryEmptyStateMessage =>
      'IntÃ©ntalo de nuevo mÃ¡s tarde o cambia de mercado en ajustes.';

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
  String get shoppingPendingSync => 'Sincronización pendiente';

  @override
  String get shoppingViewItems => 'Articulos';

  @override
  String get shoppingViewMeals => 'Comidas';

  @override
  String get shoppingViewStores => 'Tiendas';

  @override
  String get offlineBannerMessage =>
      'Modo sin conexión: los cambios se sincronizarán cuando vuelvas a estar en línea.';

  @override
  String get shoppingGroupOther => 'Otros';

  @override
  String shoppingGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articulos',
      one: '1 articulo',
    );
    return '$_temp0';
  }

  @override
  String shoppingCheapestAt(String store, String price) {
    return 'Mas barato en $store ($price)';
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
      'No se pudo conectar al servidor. Comprueba tu conexiÃ³n a internet e intÃ©ntalo de nuevo.';

  @override
  String get authErrorInvalidCredentials =>
      'Email o contraseÃ±a incorrectos. IntÃ©ntalo de nuevo.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Verifica tu email antes de iniciar sesiÃ³n.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Espera un momento e intÃ©ntalo de nuevo.';

  @override
  String get authErrorGeneric =>
      'Algo saliÃ³ mal. IntÃ©ntalo de nuevo mÃ¡s tarde.';

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
    return 'ProyecciÃ³n Ã¢â‚¬â€ $month $year';
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
  String get projectionSimulation => 'SimulaciÃ³n Ã¢â‚¬â€ no guardado';

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
    return 'Resumen Ã¢â‚¬â€ $month';
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
    return '$costÃ¢â€šÂ¬ total';
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
    return '$costâ‚¬/pers';
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
      'Puedes cambiar la configuraciÃ³n del planificador en cualquier momento en Ajustes Ã¢â€ â€™ Comidas.';

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
  String get settingsExpenses => 'Presupuesto y Pagos Recurrentes';

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
  String get settingsExpensesMonthly => 'Presupuesto y Pagos Recurrentes';

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
      'Los productos favoritos influyen en el plan de comidas â€” las recetas con esos ingredientes tienen prioridad.';

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
      'La clave se guarda localmente en el dispositivo y nunca se comparte. Usa el modelo GPT-4o mini (~â‚¬0,00008 por anÃ¡lisis).';

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
      'Eres un analista financiero personal para usuarios portugueses. Responde siempre en portuguÃ©s europeo. SÃ© directo y analÃ­tico Ã¢â‚¬â€ usa siempre nÃºmeros concretos del contexto proporcionado. Estructura la respuesta exactamente en las 3 partes pedidas. No introduzcas datos, benchmarks o referencias externas no proporcionados.';

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
      'El salario debe ser un nÃºmero positivo';

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
  String get recurringExpenses => 'Pagos Recurrentes';

  @override
  String get recurringExpenseAdd => 'AÃ±adir Pago Recurrente';

  @override
  String get recurringExpenseEdit => 'Editar Pago Recurrente';

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
      'Sin pagos recurrentes.\nAÃ±ade uno para generarlo automÃ¡ticamente cada mes.';

  @override
  String get recurringExpenseDeleteConfirm =>
      'Â¿Eliminar este pago recurrente?';

  @override
  String get recurringExpenseAutoCreated => 'Creado automÃ¡ticamente';

  @override
  String get recurringExpenseManage => 'Gestionar pagos recurrentes';

  @override
  String get recurringExpenseMarkRecurring => 'Marcar como pago recurrente';

  @override
  String get recurringExpensePopulated =>
      'Pagos recurrentes generados para este mes';

  @override
  String get recurringExpenseDayHint => 'Ej: 1 para el dÃ­a 1';

  @override
  String get recurringExpenseNoDay => 'Sin dÃ­a fijo';

  @override
  String get recurringExpenseSaved => 'Pago recurrente guardado';

  @override
  String get recurringPaymentToggle => 'Pago recurrente';

  @override
  String billsCount(int count) {
    return '$count pagos';
  }

  @override
  String get billsNone => 'Sin pagos recurrentes';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count pagos Â· $amount/mes';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Facturas ($amount) superan presupuesto';
  }

  @override
  String get billsAddBill => 'AÃ±adir Pago Recurrente';

  @override
  String get billsBudgetSettings => 'ConfiguraciÃ³n del Presupuesto';

  @override
  String get billsRecurringBills => 'Pagos Recurrentes';

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
    return 'Tuviste $amount de excedente el mes pasado Ã¢â‚¬â€ Â¿quieres asignar a un objetivo?';
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
  String get mealBatchPrepGuide => 'Cocina en Lote';

  @override
  String get mealViewPrepGuide => 'PreparaciÃ³n';

  @override
  String get mealPrepGuideTitle => 'CÃ³mo Preparar';

  @override
  String mealPrepTime(String minutes) {
    return 'Tiempo: $minutes min';
  }

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
  String get mealRateRecipe => 'Valorar receta';

  @override
  String mealRatingLabel(int rating) {
    return '$rating estrellas';
  }

  @override
  String get mealRatingUnrated => 'Sin valoracion';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get notificationSettings => 'Ajustes de Notificaciones';

  @override
  String get notificationPreferredTime => 'Hora preferida';

  @override
  String get notificationPreferredTimeDesc =>
      'Las notificaciones programadas usarÃ¡n esta hora (excepto recordatorios personalizados)';

  @override
  String get notificationBillReminders => 'Recordatorios de pagos';

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
    return 'Pago pendiente: $name';
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
      'ObtÃ©n un anÃ¡lisis en 3 partes basado en tu presupuesto real â€” no consejos genÃ©ricos.';

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
      'PuntuaciÃ³n de salud financiera 0â€“100. Toca para ver los factores.';

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
  String get onbTourExpenseTracker1Title => 'NavegaciÃ³n mensual';

  @override
  String get onbTourExpenseTracker1Body =>
      'Cambia entre meses para ver o aÃ±adir gastos de cualquier perÃ­odo.';

  @override
  String get onbTourExpenseTracker2Title => 'Resumen del presupuesto';

  @override
  String get onbTourExpenseTracker2Body =>
      'Ve tu presupuesto vs gasto real y el saldo restante de un vistazo.';

  @override
  String get onbTourExpenseTracker3Title => 'Por categorÃ­a';

  @override
  String get onbTourExpenseTracker3Body =>
      'Cada categorÃ­a muestra una barra de progreso. Toca para expandir y ver gastos individuales.';

  @override
  String get onbTourExpenseTracker4Title => 'AÃ±adir gasto';

  @override
  String get onbTourExpenseTracker4Body =>
      'Toca + para registrar un nuevo gasto. Elige la categorÃ­a y el importe.';

  @override
  String get onbTourSavings1Title => 'Tus objetivos';

  @override
  String get onbTourSavings1Body =>
      'Cada tarjeta muestra el progreso hacia tu meta. Toca para ver detalles y aÃ±adir contribuciones.';

  @override
  String get onbTourSavings2Title => 'Crear objetivo';

  @override
  String get onbTourSavings2Body =>
      'Toca + para definir un nuevo objetivo de ahorro con importe meta y fecha lÃ­mite opcional.';

  @override
  String get onbTourRecurring1Title => 'Gastos recurrentes';

  @override
  String get onbTourRecurring1Body =>
      'Facturas fijas mensuales como alquiler, suscripciones y servicios. Se incluyen automÃ¡ticamente en tu presupuesto.';

  @override
  String get onbTourRecurring2Title => 'AÃ±adir recurrente';

  @override
  String get onbTourRecurring2Body =>
      'Toca + para registrar un nuevo gasto recurrente con importe y dÃ­a de vencimiento.';

  @override
  String get onbTourAssistant1Title => 'Asistente de comandos';

  @override
  String get onbTourAssistant1Body =>
      'Tu atajo para acciones rÃ¡pidas. Toca para aÃ±adir gastos, cambiar ajustes, navegar y mÃ¡s â€” solo escribe lo que necesitas.';

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
  String get taxDeductionDetailTitle => 'Deducciones Fiscales Ã¢â‚¬â€ Detalle';

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
  String get settingsDashUpcomingBills => 'PrÃ³ximos pagos';

  @override
  String get settingsDashBudgetStreaks => 'Rachas de presupuesto';

  @override
  String get settingsDashQuickActions => 'Acciones rÃ¡pidas';

  @override
  String get upcomingBillsTitle => 'PrÃ³ximos Pagos';

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
  String get taxSimPresetRaise => '+Ã¢â€šÂ¬200 aumento';

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
      'Sugiere recetas que se pueden preparar con antelaciÃ³n para varias comidas';

  @override
  String get subtitleReuseLeftovers =>
      'Planifica comidas que reutilizan ingredientes de dÃ­as anteriores';

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
      'PuntuaciÃ³n (0-100) que mide la presiÃ³n de gastos vs ingresos';

  @override
  String get subtitleShowMonthReview =>
      'Resumen comparativo de este mes con los anteriores';

  @override
  String get subtitleShowUpcomingBills =>
      'Gastos recurrentes en los prÃ³ximos 30 dÃ­as';

  @override
  String get subtitleShowSummaryCards =>
      'Ingresos, deducciones, gastos y tasa de ahorro';

  @override
  String get subtitleShowBudgetVsActual =>
      'ComparaciÃ³n lado a lado por categorÃ­a de gasto';

  @override
  String get subtitleShowExpensesBreakdown =>
      'GrÃ¡fico circular de gastos por categorÃ­a';

  @override
  String get subtitleShowSavingsGoals =>
      'Progreso hacia tus objetivos de ahorro';

  @override
  String get subtitleShowTaxDeductions =>
      'Deducciones fiscales elegibles estimadas este aÃ±o';

  @override
  String get subtitleShowBudgetStreaks =>
      'CuÃ¡ntos meses consecutivos te mantuviste dentro del presupuesto';

  @override
  String get subtitleShowQuickActions =>
      'Atajos para aÃ±adir gastos, navegar y mÃ¡s';

  @override
  String get subtitleShowPurchaseHistory =>
      'Compras recientes de la lista de compras y costes';

  @override
  String get subtitleShowCharts =>
      'GrÃ¡ficos de tendencia de presupuesto, gastos e ingresos';

  @override
  String get subtitleChartExpensesPie =>
      'DistribuciÃ³n de gastos por categorÃ­a';

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
      'Sustituir el idioma del sistema. \"Sistema\" sigue la configuraciÃ³n del dispositivo';

  @override
  String get helperMaritalStatus =>
      'Afecta al cÃ¡lculo del tramo fiscal del IRPF';

  @override
  String get helperMealObjective =>
      'Define el patrÃ³n alimentario: omnÃ­voro, vegetariano, pescatariano, etc.';

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
      'NÃºmero de dÃ­as completamente vegetarianos por semana';

  @override
  String get helperFishDays => 'Recomendado: 2-3 veces por semana';

  @override
  String get helperLegumeDays => 'Recomendado: 2-3 veces por semana';

  @override
  String get helperRedMeatDays => 'Recomendado: mÃ¡ximo 2 veces por semana';

  @override
  String get helperMaxPrepTime =>
      'Tiempo mÃ¡ximo de cocciÃ³n para comidas entre semana (minutos)';

  @override
  String get helperMaxComplexity =>
      'Nivel de dificultad de las recetas para dÃ­as laborables';

  @override
  String get helperWeekendPrepTime =>
      'Tiempo mÃ¡ximo de cocciÃ³n para comidas de fin de semana (minutos)';

  @override
  String get helperWeekendComplexity =>
      'Nivel de dificultad de las recetas para fines de semana';

  @override
  String get helperMaxBatchDays =>
      'CuÃ¡ntos dÃ­as se puede reutilizar una comida cocinada en lote';

  @override
  String get helperNewIngredients =>
      'Limita cuÃ¡ntos ingredientes nuevos aparecen cada semana';

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
      'TÃ­pico: 22. Afecta al cÃ¡lculo del subsidio de comida';

  @override
  String get helperSalaryLabel =>
      'Un nombre para identificar esta fuente de ingresos';

  @override
  String get helperExpenseAmount =>
      'Importe mensual presupuestado para esta categorÃ­a';

  @override
  String get helperCalorieTarget => 'Recomendado: 2000-2500 kcal para adultos';

  @override
  String get helperProteinTarget => 'Recomendado: 50-70g para adultos';

  @override
  String get helperFiberTarget => 'Recomendado: 25-30g para adultos';

  @override
  String get infoStressIndex =>
      'Compara el gasto real con tu presupuesto. Rangos de puntuaciÃ³n:\n\n0-30: CÃ³modo - gasto bien dentro del presupuesto\n30-60: Moderado - acercÃ¡ndose a los lÃ­mites del presupuesto\n60-100: CrÃ­tico - el gasto excede significativamente el presupuesto';

  @override
  String get infoBudgetStreak =>
      'Meses consecutivos en los que tu gasto total se mantuvo dentro del presupuesto total.';

  @override
  String get infoUpcomingBills =>
      'Muestra gastos recurrentes en los prÃ³ximos 30 dÃ­as basÃ¡ndose en tus gastos mensuales.';

  @override
  String get infoSalaryBreakdown =>
      'Muestra cÃ³mo se divide tu salario bruto en impuesto IRPF, contribuciones a la seguridad social, ingreso neto y subsidio de comida.';

  @override
  String get infoBudgetVsActual =>
      'Compara lo que presupuestaste por categorÃ­a con lo que realmente gastaste. Verde significa por debajo del presupuesto, rojo significa por encima.';

  @override
  String get infoSavingsGoals =>
      'Progreso hacia cada objetivo de ahorro basado en las contribuciones realizadas.';

  @override
  String get infoTaxDeductions =>
      'Gastos deducibles estimados (salud, educaciÃ³n, vivienda). Son solo estimaciones - consulta a un profesional fiscal para valores precisos.';

  @override
  String get infoPurchaseHistory =>
      'Total gastado en compras de la lista de compras este mes.';

  @override
  String get infoExpensesBreakdown =>
      'Desglose visual de tus gastos por categorÃ­a del mes actual.';

  @override
  String get infoCharts =>
      'Datos de tendencia a lo largo del tiempo. Toca cualquier grÃ¡fico para una vista detallada.';

  @override
  String get infoExpenseTrackerSummary =>
      'Presupuestado = tu gasto mensual planificado. Real = lo que has gastado hasta ahora. Restante = presupuesto menos real.';

  @override
  String get infoExpenseTrackerProgress =>
      'Verde: por debajo del 75% del presupuesto. Amarillo: 75-100%. Rojo: por encima del presupuesto.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filtra gastos por texto, categorÃ­a o rango de fechas.';

  @override
  String get infoSavingsProjection =>
      'Basado en tus contribuciones mensuales medias. \"En camino\" significa que tu ritmo actual alcanza el objetivo a tiempo. \"Retrasado\" significa que necesitas aumentar las contribuciones.';

  @override
  String get infoSavingsRequired =>
      'La cantidad que necesitas ahorrar cada mes a partir de ahora para alcanzar tu objetivo en el plazo.';

  @override
  String get infoCoachModes =>
      'Eco: gratuito, sin memoria de conversaciÃ³n.\nPlus: 1 crÃ©dito por mensaje, recuerda los Ãºltimos 5 mensajes.\nPro: 2 crÃ©ditos por mensaje, memoria de conversaciÃ³n completa.';

  @override
  String get infoCoachCredits =>
      'Los crÃ©ditos se usan en los modos Plus y Pro. Recibes crÃ©ditos iniciales al registrarte. El modo Eco es siempre gratuito.';

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
      'Presupuesto mensual de alimentaciÃ³n y productos del hogar';

  @override
  String get helperWizardTransport =>
      'Costes mensuales de transporte (combustible, transporte pÃºblico, etc.)';

  @override
  String get helperWizardUtilities => 'Electricidad, agua y gas mensuales';

  @override
  String get helperWizardTelecom => 'Internet, telÃ©fono y TV mensuales';

  @override
  String get savingsGoalHowItWorksTitle => 'Â¿CÃ³mo funciona?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Crea un objetivo con un nombre y el monto que quieres ahorrar (ej: \"Vacaciones â€” 2 000 â‚¬\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Opcionalmente define una fecha lÃ­mite como referencia.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Cada vez que ahorres dinero, toca el objetivo y registra una contribuciÃ³n con el monto y la fecha.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Sigue tu progreso: la barra muestra cuÃ¡nto has ahorrado y la proyecciÃ³n estima cuÃ¡ndo alcanzarÃ¡s tu objetivo.';

  @override
  String get savingsGoalDashboardHint =>
      'Toca un objetivo para ver detalles y registrar contribuciones.';

  @override
  String get rateLimitMessage =>
      'Por favor, espera un momento antes de intentarlo de nuevo';

  @override
  String get planningExportTitle => 'Exportar';

  @override
  String get planningImportTitle => 'Importar';

  @override
  String get planningExportShoppingList => 'Exportar lista de compras';

  @override
  String get planningImportShoppingList => 'Importar lista de compras';

  @override
  String get planningExportMealPlan => 'Exportar plan de comidas';

  @override
  String get planningImportMealPlan => 'Importar plan de comidas';

  @override
  String get planningExportPantry => 'Exportar despensa';

  @override
  String get planningImportPantry => 'Importar despensa';

  @override
  String get planningExportFreeformMeals => 'Exportar comidas libres';

  @override
  String get planningImportFreeformMeals => 'Importar comidas libres';

  @override
  String get planningFormatCsv => 'CSV';

  @override
  String get planningFormatJson => 'JSON';

  @override
  String get planningImportSuccess => 'Importado con Ã©xito';

  @override
  String planningImportError(String error) {
    return 'ImportaciÃ³n fallida: $error';
  }

  @override
  String get planningExportSuccess => 'Exportado con Ã©xito';

  @override
  String get planningDataPortability => 'Portabilidad de datos';

  @override
  String get planningDataPortabilityDesc =>
      'Importar y exportar artefactos de planificaciÃ³n';

  @override
  String get mealBudgetInsightTitle => 'VisiÃ³n del Presupuesto';

  @override
  String get mealBudgetStatusSafe => 'En camino';

  @override
  String get mealBudgetStatusWatch => 'AtenciÃ³n';

  @override
  String get mealBudgetStatusOver => 'Sobre presupuesto';

  @override
  String get mealBudgetWeeklyCost => 'Coste semanal estimado';

  @override
  String get mealBudgetProjectedMonthly => 'ProyecciÃ³n mensual';

  @override
  String get mealBudgetMonthlyBudget => 'Presupuesto mensual de alimentaciÃ³n';

  @override
  String get mealBudgetRemaining => 'Presupuesto restante';

  @override
  String get mealBudgetTopExpensive => 'Comidas mÃ¡s caras';

  @override
  String get mealBudgetSuggestedSwaps => 'Cambios mÃ¡s baratos sugeridos';

  @override
  String get mealBudgetViewDetails => 'Ver detalles';

  @override
  String get mealBudgetApplySwap => 'Aplicar';

  @override
  String mealBudgetSwapSavings(String amount) {
    return 'Ahorra $amount';
  }

  @override
  String get mealBudgetDailyBreakdown => 'Desglose de coste diario';

  @override
  String get mealBudgetShoppingImpact => 'Impacto en las compras';

  @override
  String get mealBudgetUniqueIngredients => 'Ingredientes Ãºnicos';

  @override
  String get mealBudgetEstShoppingCost => 'Coste estimado de compras';

  @override
  String get productUpdatesTitle => 'Novedades del Producto';

  @override
  String get whatsNewTab => 'Novedades';

  @override
  String get roadmapTab => 'Hoja de Ruta';

  @override
  String get noUpdatesYet => 'Sin novedades todavia';

  @override
  String get noRoadmapItems => 'Sin elementos en la hoja de ruta';

  @override
  String get roadmapNow => 'Ahora';

  @override
  String get roadmapNext => 'Siguiente';

  @override
  String get roadmapLater => 'Despues';

  @override
  String get productUpdatesSubtitle => 'Changelog y funcionalidades futuras';

  @override
  String get whatsNewDialogTitle => 'Novedades';

  @override
  String get whatsNewDialogDismiss => 'Entendido';

  @override
  String get confidenceCenterTitle => 'Centro de Confianza';

  @override
  String get confidenceSyncHealth => 'Estado de SincronizaciÃ³n';

  @override
  String get confidenceDataAlerts => 'Alertas de Calidad de Datos';

  @override
  String get confidenceRecommendedActions => 'Acciones Recomendadas';

  @override
  String get confidenceCenterSubtitle =>
      'Frescura de datos y salud del sistema';

  @override
  String get confidenceCenterTile => 'Centro de Confianza';

  @override
  String get pantryPickerTitle => 'Selector de Despensa';

  @override
  String get pantrySearchHint => 'Buscar ingredientes...';

  @override
  String get pantryTabAlwaysHave => 'Siempre Tengo';

  @override
  String get pantryTabThisWeek => 'Esta Semana';

  @override
  String pantrySummaryLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artÃ­culos en despensa',
      one: '1 artÃ­culo en despensa',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Editar';

  @override
  String get pantryUseWhatWeHave => 'Usar Lo Que Tenemos';

  @override
  String get pantryMarkAtHome => 'Ya lo tengo en casa';

  @override
  String get pantryHaveIt => 'Lo tengo';

  @override
  String pantryCoverageLabel(int pct) {
    return '$pct% cubierto por la despensa';
  }

  @override
  String get pantryStaples => 'BÃSICOS (SIEMPRE EN STOCK)';

  @override
  String get pantryWeekly => 'DESPENSA DE ESTA SEMANA';

  @override
  String pantryAddedToWeekly(String name) {
    return '$name aÃ±adido a la despensa semanal';
  }

  @override
  String pantryRemovedFromList(String name) {
    return '$name eliminado de la lista (ya en casa)';
  }

  @override
  String pantryMarkedAtHome(String name) {
    return '$name marcado como ya en casa';
  }

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
      'Las acciones compartidas de tu hogar aparecerÃ¡n aquÃ­.';

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
    return 'AÃ±adido por $name';
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

  @override
  String get barcodeScanTitle => 'Escanear Codigo de Barras';

  @override
  String get barcodeScanHint => 'Apunta la camara a un codigo de barras';

  @override
  String get barcodeScanTooltip => 'Escanear codigo de barras';

  @override
  String get barcodeProductFound => 'Producto Encontrado';

  @override
  String get barcodeProductNotFound => 'Producto No Encontrado';

  @override
  String get barcodeLabel => 'Codigo de barras';

  @override
  String get barcodeAddToList => 'Agregar a la Lista';

  @override
  String get barcodeManualEntry =>
      'No se encontro ningÃºn producto. Ingresa los datos manualmente:';

  @override
  String get barcodeProductName => 'Nombre del producto';

  @override
  String get barcodePrice => 'Precio';

  @override
  String barcodeAddedToList(String name) {
    return '$name agregado a la lista de compras';
  }

  @override
  String get barcodeInvoiceDetected =>
      'Este es un cÃ³digo de factura, no de producto';

  @override
  String get barcodeInvoiceAction => 'Abrir EscÃ¡ner de Recibos';

  @override
  String get quickAddTooltip => 'Acciones rÃ¡pidas';

  @override
  String get quickAddExpense => 'AÃ±adir gasto';

  @override
  String get quickAddShopping => 'AÃ±adir artÃ­culo de compras';

  @override
  String get quickOpenMeals => 'Planificador de comidas';

  @override
  String get quickOpenAssistant => 'Asistente';

  @override
  String get freeformBadge => 'Libre';

  @override
  String get freeformCreateTitle => 'AÃ±adir comida libre';

  @override
  String get freeformEditTitle => 'Editar comida libre';

  @override
  String get freeformTitleLabel => 'TÃ­tulo de la comida';

  @override
  String get freeformTitleHint => 'ej. Sobras, Pizza a domicilio';

  @override
  String get freeformNoteLabel => 'Nota (opcional)';

  @override
  String get freeformNoteHint => 'Detalles sobre esta comida';

  @override
  String get freeformCostLabel => 'Coste estimado (opcional)';

  @override
  String get freeformTagsLabel => 'Etiquetas';

  @override
  String get freeformTagLeftovers => 'Sobras';

  @override
  String get freeformTagPantryMeal => 'Despensa';

  @override
  String get freeformTagTakeout => 'Comida para llevar';

  @override
  String get freeformTagQuickMeal => 'Comida rÃ¡pida';

  @override
  String get freeformShoppingItemsLabel => 'ArtÃ­culos de compra';

  @override
  String get freeformAddItem => 'AÃ±adir artÃ­culo';

  @override
  String get freeformItemName => 'Nombre del artÃ­culo';

  @override
  String get freeformItemQuantity => 'Cantidad';

  @override
  String get freeformItemUnit => 'Unidad';

  @override
  String get freeformItemPrice => 'Precio est.';

  @override
  String get freeformItemStore => 'Tienda';

  @override
  String freeformShoppingItemCount(int count) {
    return '$count artÃ­culos de compra';
  }

  @override
  String get freeformAddToSlot => 'AÃ±adir comida libre';

  @override
  String get freeformReplace => 'Reemplazar con comida libre';

  @override
  String get insightsTitle => 'AnÃ¡lisis';

  @override
  String get insightsAnalyzeSpending => 'Analizar gastos a lo largo del tiempo';

  @override
  String get insightsTrackProgress => 'Seguir progreso de tus metas';

  @override
  String get insightsTaxOutcome => 'Estimar resultado fiscal anual';

  @override
  String get moreTitle => 'MÃ¡s';

  @override
  String get moreDetailedDashboard => 'Panel Detallado';

  @override
  String get moreDetailedDashboardSubtitle =>
      'Abrir panel financiero completo con todas las tarjetas';

  @override
  String get moreSavingsSubtitle =>
      'Seguir y actualizar el progreso de tus metas';

  @override
  String get moreNotificationsSubtitle =>
      'Presupuestos, facturas y recordatorios';

  @override
  String get moreSettingsSubtitle => 'Preferencias, perfil y panel';

  @override
  String get morePlanFree => 'Plan Gratis';

  @override
  String get morePlanTrial => 'Prueba Activa';

  @override
  String get morePlanPro => 'Plan Pro';

  @override
  String get morePlanFamily => 'Plan Familiar';

  @override
  String get morePlanManage => 'Gestionar tu plan y facturaciÃ³n';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categorÃ­as • $goals meta de ahorro';
  }

  @override
  String moreItemsPaused(int count) {
    return '$count elementos pausados';
  }

  @override
  String get moreUpgrade => 'Mejorar →';

  @override
  String get planTitle => 'Planificar';

  @override
  String get planGrocerySubtitle => 'Explorar productos y precios';

  @override
  String get planShoppingList => 'Lista de Compras';

  @override
  String get planShoppingSubtitle => 'Revisar y finalizar compras';

  @override
  String get planMealSubtitle => 'Generar planes semanales asequibles';

  @override
  String coachActiveMemory(String mode, int percent) {
    return 'Memoria activa: $mode ($percent%)';
  }

  @override
  String get coachCostPerMessageNote =>
      'Coste por mensaje enviado. La respuesta del coach no consume crÃ©ditos.';

  @override
  String get coachExpandTip => 'Expandir aviso';

  @override
  String get coachCollapseTip => 'Minimizar aviso';

  @override
  String featureTryName(String name) {
    return 'Probar $name';
  }

  @override
  String featureExploreName(String name) {
    return 'Explorar $name';
  }

  @override
  String featureRequiresPremium(String name) {
    return '$name requiere Premium';
  }

  @override
  String get featureTapToUpgrade => 'Toca para mejorar';

  @override
  String get featureNameAiCoach => 'Coach IA';

  @override
  String get featureNameMealPlanner => 'Planificador de Comidas';

  @override
  String get featureNameExpenseTracker => 'Rastreador de Gastos';

  @override
  String get featureNameSavingsGoals => 'Metas de Ahorro';

  @override
  String get featureNameShoppingList => 'Lista de Compras';

  @override
  String get featureNameGroceryBrowser => 'Explorador de Productos';

  @override
  String get featureNameExportReports => 'Exportar Informes';

  @override
  String get featureNameTaxSimulator => 'Simulador Fiscal';

  @override
  String get featureNameDashboard => 'Panel';

  @override
  String get featureTagAiCoach => 'Tu asesor financiero personal';

  @override
  String get featureTagMealPlanner => 'Ahorra dinero en comida';

  @override
  String get featureTagExpenseTracker => 'Sabe adÃ³nde va cada euro';

  @override
  String get featureTagSavingsGoals => 'Haz realidad tus sueÃ±os';

  @override
  String get featureTagShoppingList => 'Compra de forma mÃ¡s inteligente';

  @override
  String get featureTagGroceryBrowser => 'Compara precios al instante';

  @override
  String get featureTagExportReports => 'Informes profesionales de presupuesto';

  @override
  String get featureTagTaxSimulator => 'PlanificaciÃ³n fiscal multi-paÃ­s';

  @override
  String get featureTagDashboard => 'Tu visiÃ³n financiera general';

  @override
  String get featureDescAiCoach =>
      'ObtÃ©n informaciÃ³n personalizada sobre tus hÃ¡bitos de gasto, consejos de ahorro y optimizaciÃ³n del presupuesto con IA.';

  @override
  String get featureDescMealPlanner =>
      'Planifica comidas semanales dentro de tu presupuesto. La IA genera recetas segÃºn tus preferencias y necesidades alimentarias.';

  @override
  String get featureDescExpenseTracker =>
      'Sigue los gastos reales vs. presupuesto en tiempo real. Ve dÃ³nde gastas de mÃ¡s y dÃ³nde puedes ahorrar.';

  @override
  String get featureDescSavingsGoals =>
      'Define metas de ahorro con plazos, sigue contribuciones y ve proyecciones de cuÃ¡ndo alcanzarÃ¡s tus objetivos.';

  @override
  String get featureDescShoppingList =>
      'Crea listas de compras compartidas en tiempo real. Marca artÃ­culos mientras compras, finaliza y controla gastos.';

  @override
  String get featureDescGroceryBrowser =>
      'Explora productos de varias tiendas, compara precios y aÃ±ade las mejores ofertas directamente a tu lista de compras.';

  @override
  String get featureDescExportReports =>
      'Exporta tu presupuesto, gastos y resÃºmenes financieros en PDF o CSV para tus registros o contable.';

  @override
  String get featureDescTaxSimulator =>
      'Compara obligaciones fiscales entre paÃ­ses. Perfecto para expatriados y quienes consideran mudarse.';

  @override
  String get featureDescDashboard =>
      'Ve el resumen completo del presupuesto, grÃ¡ficos y salud financiera de un vistazo.';

  @override
  String get trialPremiumActive => 'Prueba Premium Activa';

  @override
  String get trialHalfway => 'Tu prueba estÃ¡ a mitad de camino';

  @override
  String trialDaysLeftInTrial(int count) {
    return 'Â¡$count dÃ­as restantes en tu prueba!';
  }

  @override
  String get trialLastDay => 'Â¡Ãšltimo dÃ­a de tu prueba gratuita!';

  @override
  String get trialSeePlans => 'Ver Planes';

  @override
  String get trialUpgradeNow => 'Mejorar Ahora — Conserva Tus Datos';

  @override
  String get trialSubtitleUrgent =>
      'Tu acceso premium termina pronto. Mejora para conservar el Coach IA, Planificador de Comidas y todos tus datos.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'Â¿Ya probaste el $name? Â¡Aprovecha al mÃ¡ximo tu prueba!';
  }

  @override
  String get trialSubtitleMidProgress =>
      'Â¡EstÃ¡s haciendo un gran progreso! Sigue explorando funciones premium.';

  @override
  String get trialSubtitleEarly =>
      'Tienes acceso completo a todas las funciones premium. Â¡Explora todo!';

  @override
  String trialFeaturesExplored(int explored, int total) {
    return '$explored/$total funciones exploradas';
  }

  @override
  String trialDaysRemaining(int count) {
    return '$count dÃ­as restantes';
  }

  @override
  String trialProgressLabel(int percent) {
    return 'Progreso de la prueba $percent%';
  }

  @override
  String get featureNameAiCoachFull => 'Coach Financiero IA';

  @override
  String get receiptScanTitle => 'Escanear Recibo';

  @override
  String get receiptScanQrMode => 'CÃ³digo QR';

  @override
  String get receiptScanPhotoMode => 'Foto';

  @override
  String get receiptScanHint => 'Apunte la cÃ¡mara al cÃ³digo QR del recibo';

  @override
  String get receiptScanPhotoHint =>
      'Coloque el recibo y pulse el botÃ³n para capturar';

  @override
  String get receiptScanProcessing => 'Leyendo reciboâ€¦';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Gasto de $amount en $store registrado';
  }

  @override
  String get receiptScanFailed => 'No se pudo leer el recibo';

  @override
  String get receiptScanPrompt =>
      'Â¿Compras hechas? Escanea el recibo para registrar gastos automÃ¡ticamente.';

  @override
  String get receiptMerchantUnknown => 'Tienda desconocida';

  @override
  String receiptMerchantNamePrompt(String nif) {
    return 'Ingrese el nombre de la tienda para NIF $nif';
  }

  @override
  String receiptItemsMatched(int count) {
    return '$count artÃ­culos asociados a la lista de compras';
  }

  @override
  String get quickScanReceipt => 'Escanear Recibo';

  @override
  String get receiptReviewTitle => 'Revisar Recibo';

  @override
  String get receiptReviewMerchant => 'Tienda';

  @override
  String get receiptReviewDate => 'Fecha';

  @override
  String get receiptReviewTotal => 'Total';

  @override
  String get receiptReviewCategory => 'CategorÃ­a';

  @override
  String receiptReviewItems(int count) {
    return '$count artÃ­culos detectados';
  }

  @override
  String get receiptReviewConfirm => 'AÃ±adir Gasto';

  @override
  String get receiptReviewRetake => 'Repetir';

  @override
  String get receiptCameraPermissionTitle => 'Acceso a la CÃ¡mara';

  @override
  String get receiptCameraPermissionBody =>
      'Se necesita acceso a la cÃ¡mara para escanear recibos y cÃ³digos de barras.';

  @override
  String get receiptCameraPermissionAllow => 'Permitir';

  @override
  String get receiptCameraPermissionDeny => 'Ahora no';

  @override
  String get receiptCameraBlockedTitle => 'CÃ¡mara Bloqueada';

  @override
  String get receiptCameraBlockedBody =>
      'El permiso de la cÃ¡mara fue denegado permanentemente. Abra la configuraciÃ³n para activarlo.';

  @override
  String get receiptCameraBlockedSettings => 'Abrir ConfiguraciÃ³n';

  @override
  String groceryMarketData(String marketCode) {
    return 'Datos del mercado $marketCode';
  }

  @override
  String groceryStoreCoverage(int active, int total) {
    return '$active tiendas activas de $total';
  }

  @override
  String groceryStoreFreshCount(int count) {
    return '$count fresca';
  }

  @override
  String groceryStorePartialCount(int count) {
    return '$count parcial';
  }

  @override
  String groceryStoreFailedCount(int count) {
    return '$count fallida';
  }

  @override
  String get groceryHideStaleStores => 'Ocultar tiendas desactualizadas';

  @override
  String groceryComparisonsFreshOnly(int count) {
    return 'Mostrando $count tienda fresca en comparaciones';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get navHomeTip => 'Resumen mensual';

  @override
  String get navTrack => 'Gastos';

  @override
  String get navTrackTip => 'Registrar gastos mensuales';

  @override
  String get navPlan => 'Planear';

  @override
  String get navPlanTip => 'Supermercado, lista y plan de comidas';

  @override
  String get navPlanAndShop => 'Compras';

  @override
  String get navPlanAndShopTip => 'Lista de compras, supermercado y comidas';

  @override
  String get navMore => 'MÃ¡s';

  @override
  String get navMoreTip => 'Ajustes y anÃ¡lisis';

  @override
  String get paywallContinueFree => 'Continuando con el plan gratuito';

  @override
  String get paywallUpgradedPro => 'Actualizado a Pro â€” Â¡gracias!';

  @override
  String get paywallNoRestore => 'No se encontraron compras anteriores';

  @override
  String get paywallRestoredPro => 'Â¡SuscripciÃ³n Pro restaurada!';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Prueba ($count dÃ­as restantes)';
  }

  @override
  String get authConnectionError => 'Error de conexiÃ³n';

  @override
  String get authRetry => 'Reintentar';

  @override
  String get authSignOut => 'Cerrar sesiÃ³n';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get settingsGroupAccount => 'CUENTA';

  @override
  String get settingsGroupBudget => 'PRESUPUESTO';

  @override
  String get settingsGroupPreferences => 'PREFERENCIAS';

  @override
  String get settingsGroupAdvanced => 'AVANZADO';

  @override
  String get settingsManageSubscription => 'Gestionar SuscripciÃ³n';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get mealShowDetails => 'Mostrar detalles';

  @override
  String get mealHideDetails => 'Ocultar detalles';

  @override
  String get taxSimTitularesHint =>
      'NÃºmero de titulares de ingresos en el hogar';

  @override
  String get taxSimMealTypeHint =>
      'Tarjeta: exento de impuestos hasta el lÃ­mite legal. Efectivo: tributado como ingreso.';

  @override
  String get taxSimIRSFull => 'IRPF (Impuesto sobre la Renta) retenciÃ³n';

  @override
  String get taxSimSSFull => 'SS (Seguridad Social)';

  @override
  String get stressZoneCritical =>
      '0â€“39: Alta presiÃ³n financiera, acciÃ³n urgente necesaria';

  @override
  String get stressZoneWarning =>
      '40â€“59: Algunos riesgos presentes, mejoras recomendadas';

  @override
  String get stressZoneGood =>
      '60â€“79: Finanzas saludables, pequeÃ±as optimizaciones posibles';

  @override
  String get stressZoneExcellent =>
      '80â€“100: PosiciÃ³n financiera fuerte, bien gestionada';

  @override
  String get projectionStressHint =>
      'CÃ³mo este escenario de gastos afecta tu puntuaciÃ³n general de salud financiera (0â€“100)';

  @override
  String get coachWelcomeTitle => 'Tu Coach Financiero IA';

  @override
  String get coachWelcomeBody =>
      'Pregunta sobre tu presupuesto, gastos o ahorros. El coach analiza tus datos financieros reales para darte consejos personalizados.';

  @override
  String get coachWelcomeCredits =>
      'Los crÃ©ditos se usan en los modos Plus y Pro. El modo Eco es siempre gratuito.';

  @override
  String get coachWelcomeRateLimit =>
      'Para garantizar respuestas de calidad, hay una breve pausa entre mensajes.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Comprar crÃ©ditos';

  @override
  String get coachContinueEco => 'Continuar con Eco';

  @override
  String get coachAchieved => 'Â¡Lo logrÃ©!';

  @override
  String get coachNotYet => 'AÃºn no';

  @override
  String coachCreditsAdded(int count) {
    return '+$count crÃ©ditos aÃ±adidos';
  }

  @override
  String coachPurchaseError(String error) {
    return 'Error en la compra: $error';
  }

  @override
  String coachUseMode(String mode) {
    return 'Usar $mode';
  }

  @override
  String coachKeepMode(String mode) {
    return 'Mantener $mode';
  }

  @override
  String savingsGoalSaveError(String error) {
    return 'Error al guardar objetivo: $error';
  }

  @override
  String savingsGoalDeleteError(String error) {
    return 'Error al eliminar objetivo: $error';
  }

  @override
  String savingsGoalUpdateError(String error) {
    return 'Error al actualizar objetivo: $error';
  }

  @override
  String get settingsSubscription => 'SuscripciÃ³n';

  @override
  String get settingsSubscriptionFree => 'Gratuito';

  @override
  String settingsActiveCategoriesCount(int active, int total) {
    return 'CategorÃ­as Activas ($active de $total)';
  }

  @override
  String get settingsPausedCategories => 'CategorÃ­as Pausadas';

  @override
  String get settingsOpenDashboard => 'Abrir Dashboard Detallado';

  @override
  String get settingsAssistantGroup => 'ASISTENTE';

  @override
  String get settingsAiCoach => 'Coach IA';

  @override
  String get setupWizardSubsidyLabel => 'SUBSIDIOS';

  @override
  String get setupWizardPerDay => '/dÃ­a';

  @override
  String get configurationError => 'Error de ConfiguraciÃ³n';

  @override
  String get confidenceAllHealthy =>
      'Todos los sistemas saludables. No se requieren acciones.';

  @override
  String get confidenceNoAlerts => 'Sin alertas. Todo en orden.';

  @override
  String get onbSwipeHint => 'Desliza para continuar';

  @override
  String onbSlideOf(int current, int total) {
    return 'Diapositiva $current de $total';
  }

  @override
  String get expenseTrendsChartLabel =>
      'GrÃ¡fico de tendencias de gastos mostrando presupuesto versus gastos reales';

  @override
  String get customCategories => 'CategorÃ­as';

  @override
  String get customCategoryAdd => 'AÃ±adir CategorÃ­a';

  @override
  String get customCategoryEdit => 'Editar CategorÃ­a';

  @override
  String get customCategoryDelete => 'Eliminar CategorÃ­a';

  @override
  String get customCategoryDeleteConfirm => 'Â¿Eliminar esta categorÃ­a?';

  @override
  String get customCategoryName => 'Nombre de categorÃ­a';

  @override
  String get customCategoryIcon => 'Icono';

  @override
  String get customCategoryColor => 'Color';

  @override
  String get customCategoryEmpty => 'Sin categorÃ­as personalizadas';

  @override
  String get customCategorySaved => 'CategorÃ­a guardada';

  @override
  String get customCategoryInUse => 'CategorÃ­a en uso, no se puede eliminar';

  @override
  String get customCategoryPredefinedHint =>
      'CategorÃ­as predefinidas usadas en toda la aplicaciÃ³n';

  @override
  String get customCategoryDefault => 'Predefinida';

  @override
  String get expenseLocationPermissionDenied =>
      'Permiso de ubicaciÃ³n denegado';

  @override
  String get expenseAttachPhoto => 'Adjuntar Foto';

  @override
  String get expenseAttachCamera => 'CÃ¡mara';

  @override
  String get expenseAttachGallery => 'GalerÃ­a';

  @override
  String get expenseAttachUploadFailed =>
      'Error al subir anexos. Verifique su conexiÃ³n.';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Detectar ubicaciÃ³n';

  @override
  String get biometricLockTitle => 'Bloqueo de App';

  @override
  String get biometricLockSubtitle =>
      'Requerir autenticaciÃ³n al abrir la aplicaciÃ³n';

  @override
  String get biometricPrompt => 'AutentÃ­cate para continuar';

  @override
  String get biometricReason =>
      'Verifica tu identidad para desbloquear la aplicaciÃ³n';

  @override
  String get biometricRetry => 'Intentar de Nuevo';

  @override
  String get notifDailyExpenseReminder => 'Recordatorio diario de gastos';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Te recuerda registrar los gastos del dÃ­a';

  @override
  String get notifDailyExpenseTitle => 'Â¡No olvides tus gastos!';

  @override
  String get notifDailyExpenseBody =>
      'TÃ³mate un momento para registrar los gastos de hoy';

  @override
  String get settingsSalaryLabelHint => 'ej: Empleo principal, Freelance';

  @override
  String get settingsExpenseNameLabel => 'NOMBRE DEL GASTO';

  @override
  String get settingsCategoryLabel => 'CATEGORÃA';

  @override
  String get settingsMonthlyBudgetLabel => 'PRESUPUESTO MENSUAL';

  @override
  String get expenseLocationSearch => 'Buscar';

  @override
  String get expenseLocationSearchHint => 'Buscar direcciÃ³n...';

  @override
  String get dashboardBurnRateTitle => 'Velocidad de Gasto';

  @override
  String get dashboardBurnRateSubtitle =>
      'Promedio diario vs presupuesto disponible';

  @override
  String get dashboardBurnRateOnTrack => 'En camino';

  @override
  String get dashboardBurnRateOver => 'Sobre el ritmo';

  @override
  String get dashboardBurnRateDailyAvg => 'MEDIA/DÃA';

  @override
  String get dashboardBurnRateAllowance => 'DISP./DÃA';

  @override
  String get dashboardBurnRateDaysLeft => 'DÃAS RESTANTES';

  @override
  String get dashboardTopCategoriesTitle => 'Top CategorÃ­as';

  @override
  String get dashboardTopCategoriesSubtitle =>
      'CategorÃ­as con mÃ¡s gastos este mes';

  @override
  String get dashboardCashFlowTitle => 'PrevisiÃ³n de Flujo';

  @override
  String get dashboardCashFlowSubtitle => 'Saldo proyectado hasta fin de mes';

  @override
  String get dashboardCashFlowProjectedSpend => 'GASTO PROYECTADO';

  @override
  String get dashboardCashFlowEndOfMonth => 'FIN DE MES';

  @override
  String dashboardCashFlowPendingBills(String amount) {
    return 'Facturas pendientes: $amount';
  }

  @override
  String get dashboardSavingsRateTitle => 'Tasa de Ahorro';

  @override
  String get dashboardSavingsRateSubtitle => 'Porcentaje de ingreso ahorrado';

  @override
  String dashboardSavingsRateSaved(String amount) {
    return 'Ahorrado este mes: $amount';
  }

  @override
  String get dashboardCoachInsightTitle => 'Consejo Financiero';

  @override
  String get dashboardCoachInsightSubtitle =>
      'Sugerencia personalizada del asistente financiero';

  @override
  String get dashboardCoachLowSavings =>
      'Tu tasa de ahorro estÃ¡ por debajo del 10%. Identifica un gasto que puedas reducir este mes.';

  @override
  String get dashboardCoachHighSpending =>
      'Los gastos se acercan a tus ingresos. Revisa los gastos no esenciales.';

  @override
  String get dashboardCoachGoodSavings =>
      'Â¡Excelente! EstÃ¡s ahorrando mÃ¡s del 20%. Â¡Sigue asÃ­!';

  @override
  String get dashboardCoachGeneral =>
      'Toca para obtener anÃ¡lisis personalizados de tu presupuesto.';

  @override
  String get dashGroupInsights => 'AnÃ¡lisis';

  @override
  String get dashReorderHint => 'Arrastra para reordenar las tarjetas';

  @override
  String get settingsSalarySummaryGross => 'Bruto';

  @override
  String get settingsSalarySummaryNet => 'Neto';

  @override
  String get settingsDeductionIrs => 'IRPF';

  @override
  String get settingsDeductionSs => 'SS';

  @override
  String get settingsDeductionMeal => 'Comida';

  @override
  String settingsMealMonthlyTotal(String amount) {
    return 'Total mensual: $amount';
  }

  @override
  String get mealSubstituteIngredient => 'Sustituir ingrediente';

  @override
  String mealSubstituteTitle(String name) {
    return 'Sustituir $name';
  }

  @override
  String mealSubstitutionApplied(String oldName, String newName) {
    return '$oldName sustituido por $newName';
  }

  @override
  String get mealSubstitutionAdapting => 'Adaptando receta...';

  @override
  String get mealPlanWithPantry => 'Planificar con lo que tengo';

  @override
  String get mealPantrySelectTitle => 'Seleccionar ingredientes de la despensa';

  @override
  String get mealPantrySelectHint => 'Elige ingredientes que tienes en casa';

  @override
  String mealPantrySelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get mealPantryApply => 'Aplicar y generar';

  @override
  String get mealTasteProfileBoost => 'Perfil de gusto aplicado';

  @override
  String get mealPlanUndoMessage => 'Plan regenerado con Ã©xito';

  @override
  String get mealPlanUndoAction => 'Deshacer';

  @override
  String get mealActiveTime => 'activo';

  @override
  String get mealPassiveTime => 'horno/espera';

  @override
  String get mealOptimizeMacros => 'Optimizar macros';

  @override
  String mealSwapSuggestion(String current, String suggested) {
    return 'Cambiar $current por $suggested';
  }

  @override
  String mealSwapReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get mealApplySwap => 'Aplicar';

  @override
  String get mealSwapSameType => 'Mismo tipo';

  @override
  String get mealSwapAllTypes => 'Todos los tipos';

  @override
  String get pantryManagerTitle => 'Despensa';

  @override
  String get pantryManagerSave => 'Guardar';

  @override
  String get pantryLowStock => 'Stock bajo';

  @override
  String get pantryDepleted => 'Agotado';

  @override
  String get pantryRestock => 'Reponer';

  @override
  String get pantryQuantity => 'Cantidad';

  @override
  String get nutritionDashboardTitle => 'NutriciÃ³n Semanal';

  @override
  String get nutritionCalories => 'CalorÃ­as';

  @override
  String get nutritionProtein => 'ProteÃ­na';

  @override
  String get nutritionCarbs => 'Carbohidratos';

  @override
  String get nutritionFat => 'Grasa';

  @override
  String get nutritionFiber => 'Fibra';

  @override
  String get nutritionTopProteins => 'Top proteÃ­nas';

  @override
  String get nutritionDailyAvg => 'Promedio diario';

  @override
  String get mealWasteEstimate => 'Desperdicio estimado';

  @override
  String mealWasteExcess(String qty, String unit) {
    return '$qty $unit de exceso';
  }

  @override
  String mealWasteSuggestion(String ingredient) {
    return 'Considere duplicar esta receta para usar $ingredient';
  }

  @override
  String mealWasteCost(String cost) {
    return '~$cost desperdicio';
  }
}
