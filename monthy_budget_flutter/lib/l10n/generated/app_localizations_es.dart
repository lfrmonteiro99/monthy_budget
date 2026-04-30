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
    return 'Los gastos reales superaron lo planificado en $amountââ€šÂ¬ — Â¿ajustar valores en configuración?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Ahorró $amountââ€šÂ¬ más de lo previsto — puede reforzar el fondo de emergencia.';
  }

  @override
  String get monthReviewOnTrack =>
      'Gastos dentro de lo previsto. Buen control presupuestario.';

  @override
  String get dashboardTitle => 'Presupuesto Mensual';

  @override
  String get dashboardViewFullReport => 'Ver Informe Completo';

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
      'Â¿Estás seguro de que quieres eliminar todos los análisis guardados?';

  @override
  String get coachDeleteLabel => 'Eliminar análisis';

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
  String get cmdTemplateOpenList => 'Abre la lista de compras';

  @override
  String get cmdTemplateOpenSettings => 'Abre los ajustes';

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
    return '$name añadido a la lista';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit · precio medio';
  }

  @override
  String get groceryAvailabilityTitle => 'Disponibilidad de datos';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Mercado: $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh frescas · $partial parciales · $failed no disponibles';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Algunas tiendas tienen datos parciales o desactualizados. Las comparaciones pueden estar incompletas.';

  @override
  String get groceryEmptyStateTitle =>
      'No hay datos de supermercado disponibles';

  @override
  String get groceryEmptyStateMessage =>
      'Inténtalo de nuevo más tarde o cambia de mercado en ajustes.';

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
  String get shoppingHowMuchSpent => 'Â¿CUÁNTO GASTÉ EN TOTAL? (opcional)';

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
  String get shoppingSyncPending =>
      'Sincronizando — intenta de nuevo en un momento';

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
      'Â¡Cuenta creada! Revisa tu email para verificar la cuenta antes de iniciar sesión.';

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
  String get monthReview => 'Resumen del mes';

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
  String get mealPlannerPreviousMonth => 'Mes anterior';

  @override
  String get mealPlannerNextMonth => 'Mes siguiente';

  @override
  String get mealPlannerFullMonthView => 'Mes completo';

  @override
  String get mealPlannerWeekView => 'Semana';

  @override
  String get mealBudgetLabel => 'Presupuesto alimentación';

  @override
  String get mealPeopleLabel => 'Personas en el hogar';

  @override
  String get mealGeneratePlan => 'Generar Plan Mensual';

  @override
  String get mealGenerating => 'Generando...';

  @override
  String get mealRegenerateTitle => 'Â¿Regenerar plan?';

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
    return '$costââ€šÂ¬ total';
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
      'Â¿Qué comidas quieres incluir en el plan diario?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight del presupuesto';
  }

  @override
  String get wizardObjectiveQuestion =>
      'Â¿Cuál es el objetivo principal de tu plan alimentario?';

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
      'Puedes cambiar la configuración del planificador en cualquier momento en Ajustes ââ€ ’ Comidas.';

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
  String get settingsExpenses => 'Presupuesto y Pagos Recurrentes';

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
  String get settingsCodeCopied => 'Â¡Código copiado!';

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
      'Â¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settingsLogoutConfirmButton => 'Cerrar sesión';

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
  String get settingsMealAdvanced => 'Avanzado';

  @override
  String get settingsMealAdvancedSubtitle =>
      'Reiniciar asistente de configuración';

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
  String get setupWizardCountryTitle => 'Â¿Dónde vives?';

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
  String get setupWizardSalaryTitle => 'Â¿Cuál es tu salario?';

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
  String get setupWizardCompleteTitle => 'Â¡Todo listo!';

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
  String get expenseTrackerDeleteConfirm => 'Â¿Eliminar este gasto?';

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
  String get recurringExpenses => 'Pagos Recurrentes';

  @override
  String get recurringExpenseAdd => 'Añadir Pago Recurrente';

  @override
  String get recurringExpenseEdit => 'Editar Pago Recurrente';

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
      'Sin pagos recurrentes.\nAñade uno para generarlo automáticamente cada mes.';

  @override
  String get recurringExpenseDeleteConfirm =>
      'Â¿Eliminar este pago recurrente?';

  @override
  String get recurringExpenseAutoCreated => 'Creado automáticamente';

  @override
  String get recurringExpenseManage => 'Gestionar pagos recurrentes';

  @override
  String get recurringExpenseMarkRecurring => 'Marcar como pago recurrente';

  @override
  String get recurringExpensePopulated =>
      'Pagos recurrentes generados para este mes';

  @override
  String get recurringExpenseDayHint => 'Ej: 1 para el día 1';

  @override
  String get recurringExpenseNoDay => 'Sin día fijo';

  @override
  String get recurringExpenseSaved => 'Pago recurrente guardado';

  @override
  String get recurringExpenseSaveError =>
      'No se pudo guardar — intenta de nuevo';

  @override
  String get recurringExpenseDeleteError =>
      'No se pudo eliminar — intenta de nuevo';

  @override
  String get savingsContributionSaveError =>
      'No se pudo guardar la contribucion — intenta de nuevo';

  @override
  String get coachNoApiKeyTitle => 'Configura tu coach';

  @override
  String get coachNoApiKeyBody =>
      'Anade una clave OpenAI en Ajustes para comenzar a chatear.';

  @override
  String get coachNoApiKeyAction => 'Abrir Ajustes';

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
    return '$count pagos · $amount/mes';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Facturas ($amount) superan presupuesto';
  }

  @override
  String get billsAddBill => 'Añadir Pago Recurrente';

  @override
  String get billsBudgetSettings => 'Configuración del Presupuesto';

  @override
  String get billsRecurringBills => 'Pagos Recurrentes';

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
  String get savingsGoalCompleted => 'Â¡Objetivo alcanzado!';

  @override
  String get savingsGoalEmpty =>
      'Sin objetivos de ahorro.\nCrea uno para seguir tu progreso.';

  @override
  String get savingsGoalDeleteConfirm => 'Â¿Eliminar este objetivo?';

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
    return 'Tuviste $amount de excedente el mes pasado — Â¿quieres asignar a un objetivo?';
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
  String get mealVariation => 'Variación';

  @override
  String get mealPairing => 'Maridaje';

  @override
  String get mealStorage => 'Conservación';

  @override
  String get mealLeftover => 'Sobras';

  @override
  String get mealLeftoverIdea => 'Idea de transformación';

  @override
  String get mealWeeklySummary => 'Nutrición Semanal';

  @override
  String get mealBatchPrepGuide => 'Cocina en Lote';

  @override
  String get mealViewPrepGuide => 'Preparación';

  @override
  String get mealPrepGuideTitle => 'Cómo Preparar';

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
      'Las notificaciones programadas usarán esta hora (excepto recordatorios personalizados)';

  @override
  String get notificationBillReminders => 'Recordatorios de pagos';

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
  String get notificationCustomDeleteConfirm => 'Â¿Eliminar este recordatorio?';

  @override
  String get notificationEmpty => 'Sin recordatorios personalizados.';

  @override
  String notificationBillTitle(String name) {
    return 'Pago pendiente: $name';
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
  String get exportMonthlySummary => 'Resumen Mensual';

  @override
  String get exportMonthlySummaryDesc =>
      'Ingresos, presupuesto vs real y tasa de ahorro';

  @override
  String get exportSectionIncome => 'Ingresos';

  @override
  String get exportSectionSummary => 'Resumen Mensual';

  @override
  String get exportLabelTotalIncome => 'Ingreso Neto Total';

  @override
  String get exportLabelGrossIncome => 'Ingreso Bruto';

  @override
  String get exportLabelDeductions => 'Deducciones';

  @override
  String get exportLabelTotalExpenses => 'Total de Gastos';

  @override
  String get exportLabelNetLiquidity => 'Liquidez Mensual';

  @override
  String get exportLabelSavingsRate => 'Tasa de Ahorro';

  @override
  String get exportLabelTotal => 'Total';

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
  String get expenseTypeLabel => 'TIPO';

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
      'Tu atajo para acciones rápidas. Toca para añadir gastos, cambiar ajustes, navegar y más — solo escribe lo que necesitas.';

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
  String get settingsDashUpcomingBills => 'Próximos pagos';

  @override
  String get settingsDashBudgetStreaks => 'Rachas de presupuesto';

  @override
  String get settingsDashQuickActions => 'Acciones rápidas';

  @override
  String get upcomingBillsTitle => 'Próximos Pagos';

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
  String get taxSimPresetRaise => '+ââ€šÂ¬200 aumento';

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
      'Deje vacío para usar el presupuesto base';

  @override
  String get settingsPersonalTip =>
      'El estado civil y los dependientes afectan su tramo de IRPF, lo que determina cuánto impuesto se retiene de su salario.';

  @override
  String get settingsSalariesTip =>
      'El salario bruto se usa para calcular el ingreso neto después de impuestos y seguridad social. Añada varios salarios si el hogar tiene más de un ingreso.';

  @override
  String get settingsExpensesTip =>
      'Defina el presupuesto mensual para cada categoría. Puede ajustarlo para meses específicos en la vista de detalle.';

  @override
  String get settingsMealHouseholdTip =>
      'Número de personas que comen en casa. Esto ajusta recetas y porciones en el plan de comidas.';

  @override
  String get settingsHouseholdTip =>
      'Invite a familiares para compartir datos del presupuesto entre dispositivos. Todos los miembros ven los mismos gastos y presupuestos.';

  @override
  String get subscriptionTitle => 'Suscripción';

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
    return '$count días restantes';
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
  String get subscriptionManage => 'Gestionar Suscripción';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total funciones exploradas';
  }

  @override
  String get subscriptionTrialBannerTitle => 'Prueba Premium Activa';

  @override
  String subscriptionTrialEndingSoon(int count) {
    return 'Â¡$count días restantes en tu prueba!';
  }

  @override
  String get subscriptionTrialLastDay => 'Â¡Último día de tu prueba gratuita!';

  @override
  String get subscriptionUpgradeNow => 'Actualizar Ahora';

  @override
  String get subscriptionKeepData => 'Mantener Tus Datos';

  @override
  String get subscriptionCancelAnytime => 'Cancela en cualquier momento';

  @override
  String get subscriptionNoHiddenFees => 'Sin cargos ocultos';

  @override
  String get subscriptionMostPopular => 'Más Popular';

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
  String get subscriptionPerYear => '/año';

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
    return '$feature requiere una suscripción de pago';
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
  String get subtitleShowQuickActions =>
      'Atajos para añadir gastos, navegar y más';

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
  String get savingsGoalHowItWorksTitle => 'Â¿Cómo funciona?';

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
  String get planningImportSuccess => 'Importado con éxito';

  @override
  String planningImportError(String error) {
    return 'Importación fallida: $error';
  }

  @override
  String get planningExportSuccess => 'Exportado con éxito';

  @override
  String get planningDataPortability => 'Portabilidad de datos';

  @override
  String get planningDataPortabilityDesc =>
      'Importar y exportar artefactos de planificación';

  @override
  String get mealBudgetInsightTitle => 'Visión del Presupuesto';

  @override
  String get mealBudgetStatusSafe => 'En camino';

  @override
  String get mealBudgetStatusWatch => 'Atención';

  @override
  String get mealBudgetStatusOver => 'Sobre presupuesto';

  @override
  String get mealBudgetWeeklyCost => 'Coste semanal estimado';

  @override
  String get mealBudgetProjectedMonthly => 'Proyección mensual';

  @override
  String get mealBudgetMonthlyBudget => 'Presupuesto mensual de alimentación';

  @override
  String get mealBudgetRemaining => 'Presupuesto restante';

  @override
  String get mealBudgetTopExpensive => 'Comidas más caras';

  @override
  String get mealBudgetSuggestedSwaps => 'Cambios más baratos sugeridos';

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
  String get mealBudgetUniqueIngredients => 'Ingredientes únicos';

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
  String get confidenceSyncHealth => 'Estado de Sincronización';

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
      other: '$count artículos en despensa',
      one: '1 artículo en despensa',
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
  String get pantryStaples => 'BÁSICOS (SIEMPRE EN STOCK)';

  @override
  String get pantryWeekly => 'DESPENSA DE ESTA SEMANA';

  @override
  String pantryAddedToWeekly(String name) {
    return '$name añadido a la despensa semanal';
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
      'No se encontro ningún producto. Ingresa los datos manualmente:';

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
      'Este es un código de factura, no de producto';

  @override
  String get barcodeInvoiceAction => 'Abrir Escáner de Recibos';

  @override
  String get quickAddTooltip => 'Acciones rápidas';

  @override
  String get quickAddExpense => 'Añadir gasto';

  @override
  String get quickAddShopping => 'Añadir artículo de compras';

  @override
  String get quickOpenMeals => 'Planificador de comidas';

  @override
  String get quickOpenAssistant => 'Asistente';

  @override
  String get freeformBadge => 'Libre';

  @override
  String get freeformCreateTitle => 'Añadir comida libre';

  @override
  String get freeformEditTitle => 'Editar comida libre';

  @override
  String get freeformTitleLabel => 'Título de la comida';

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
  String get freeformTagQuickMeal => 'Comida rápida';

  @override
  String get freeformShoppingItemsLabel => 'Artículos de compra';

  @override
  String get freeformAddItem => 'Añadir artículo';

  @override
  String get freeformItemName => 'Nombre del artículo';

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
    return '$count artículos de compra';
  }

  @override
  String get freeformAddToSlot => 'Añadir comida libre';

  @override
  String get freeformReplace => 'Reemplazar con comida libre';

  @override
  String get insightsTitle => 'Análisis';

  @override
  String get insightsAnalyzeSpending => 'Analizar gastos a lo largo del tiempo';

  @override
  String get insightsTrackProgress => 'Seguir progreso de tus metas';

  @override
  String get insightsTaxOutcome => 'Estimar resultado fiscal anual';

  @override
  String get moreTitle => 'Más';

  @override
  String get moreDetailedDashboard => 'Panel Detallado';

  @override
  String get moreDetailedDashboardSubtitle =>
      'Abrir panel financiero completo con todas las tarjetas';

  @override
  String get moreSavingsSubtitle =>
      'Seguir y actualizar el progreso de tus metas';

  @override
  String get moreCoachSubtitle =>
      'Consejos personalizados sobre tu presupuesto';

  @override
  String get moreYearlySummarySubtitle =>
      'Resumen anual y tendencias mensuales';

  @override
  String get navMore => 'Más';

  @override
  String get navMoreTip => 'Ajustes y análisis';

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
  String get morePlanManage => 'Gestionar tu plan y facturación';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categorías • $goals meta de ahorro';
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
      'Coste por mensaje enviado. La respuesta del coach no consume créditos.';

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
  String get featureTagExpenseTracker => 'Sabe adónde va cada euro';

  @override
  String get featureTagSavingsGoals => 'Haz realidad tus sueños';

  @override
  String get featureTagShoppingList => 'Compra de forma más inteligente';

  @override
  String get featureTagGroceryBrowser => 'Compara precios al instante';

  @override
  String get featureTagExportReports => 'Informes profesionales de presupuesto';

  @override
  String get featureTagTaxSimulator => 'Planificación fiscal multi-país';

  @override
  String get featureTagDashboard => 'Tu visión financiera general';

  @override
  String get featureDescAiCoach =>
      'Obtén información personalizada sobre tus hábitos de gasto, consejos de ahorro y optimización del presupuesto con IA.';

  @override
  String get featureDescMealPlanner =>
      'Planifica comidas semanales dentro de tu presupuesto. La IA genera recetas según tus preferencias y necesidades alimentarias.';

  @override
  String get featureDescExpenseTracker =>
      'Sigue los gastos reales vs. presupuesto en tiempo real. Ve dónde gastas de más y dónde puedes ahorrar.';

  @override
  String get featureDescSavingsGoals =>
      'Define metas de ahorro con plazos, sigue contribuciones y ve proyecciones de cuándo alcanzarás tus objetivos.';

  @override
  String get featureDescShoppingList =>
      'Crea listas de compras compartidas en tiempo real. Marca artículos mientras compras, finaliza y controla gastos.';

  @override
  String get featureDescGroceryBrowser =>
      'Explora productos de varias tiendas, compara precios y añade las mejores ofertas directamente a tu lista de compras.';

  @override
  String get featureDescExportReports =>
      'Exporta tu presupuesto, gastos y resúmenes financieros en PDF o CSV para tus registros o contable.';

  @override
  String get featureDescTaxSimulator =>
      'Compara obligaciones fiscales entre países. Perfecto para expatriados y quienes consideran mudarse.';

  @override
  String get featureDescDashboard =>
      'Ve el resumen completo del presupuesto, gráficos y salud financiera de un vistazo.';

  @override
  String get trialPremiumActive => 'Prueba Premium Activa';

  @override
  String get trialHalfway => 'Tu prueba está a mitad de camino';

  @override
  String trialDaysLeftInTrial(int count) {
    return 'Â¡$count días restantes en tu prueba!';
  }

  @override
  String get trialLastDay => 'Â¡Último día de tu prueba gratuita!';

  @override
  String get trialSeePlans => 'Ver Planes';

  @override
  String get trialUpgradeNow => 'Mejorar Ahora — Conserva Tus Datos';

  @override
  String get trialSubtitleUrgent =>
      'Tu acceso premium termina pronto. Mejora para conservar el Coach IA, Planificador de Comidas y todos tus datos.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'Â¿Ya probaste el $name? Â¡Aprovecha al máximo tu prueba!';
  }

  @override
  String get trialSubtitleMidProgress =>
      'Â¡Estás haciendo un gran progreso! Sigue explorando funciones premium.';

  @override
  String get trialSubtitleEarly =>
      'Tienes acceso completo a todas las funciones premium. Â¡Explora todo!';

  @override
  String trialFeaturesExplored(int explored, int total) {
    return '$explored/$total funciones exploradas';
  }

  @override
  String trialDaysRemaining(int count) {
    return '$count días restantes';
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
  String get receiptScanQrMode => 'Código QR';

  @override
  String get receiptScanPhotoMode => 'Foto';

  @override
  String get receiptScanHint => 'Apunte la cámara al código QR del recibo';

  @override
  String get receiptScanPhotoHint =>
      'Coloque el recibo y pulse el botón para capturar';

  @override
  String get receiptScanProcessing => 'Leyendo recibo…';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Gasto de $amount en $store registrado';
  }

  @override
  String get receiptScanFailed => 'No se pudo leer el recibo';

  @override
  String get receiptScanPrompt =>
      'Â¿Compras hechas? Escanea el recibo para registrar gastos automáticamente.';

  @override
  String get receiptMerchantUnknown => 'Tienda desconocida';

  @override
  String receiptMerchantNamePrompt(String nif) {
    return 'Ingrese el nombre de la tienda para NIF $nif';
  }

  @override
  String receiptItemsMatched(int count) {
    return '$count artículos asociados a la lista de compras';
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
  String get receiptReviewCategory => 'Categoría';

  @override
  String receiptReviewItems(int count) {
    return '$count artículos detectados';
  }

  @override
  String get receiptReviewConfirm => 'Añadir Gasto';

  @override
  String get receiptReviewRetake => 'Repetir';

  @override
  String get receiptCameraPermissionTitle => 'Acceso a la Cámara';

  @override
  String get receiptCameraPermissionBody =>
      'Se necesita acceso a la cámara para escanear recibos y códigos de barras.';

  @override
  String get receiptCameraPermissionAllow => 'Permitir';

  @override
  String get receiptCameraPermissionDeny => 'Ahora no';

  @override
  String get receiptCameraBlockedTitle => 'Cámara Bloqueada';

  @override
  String get receiptCameraBlockedBody =>
      'El permiso de la cámara fue denegado permanentemente. Abra la configuración para activarlo.';

  @override
  String get receiptCameraBlockedSettings => 'Abrir Configuración';

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
  String get paywallContinueFree => 'Continuar gratis';

  @override
  String get paywallUpgradedPro => 'Actualizado a Pro — Â¡gracias!';

  @override
  String get paywallNoRestore => 'No se encontraron compras anteriores';

  @override
  String get paywallRestoredPro => 'Â¡Suscripción Pro restaurada!';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Prueba ($count días restantes)';
  }

  @override
  String get authConnectionError => 'Error de conexión';

  @override
  String get authRetry => 'Reintentar';

  @override
  String get authSignOut => 'Cerrar sesión';

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
  String get settingsManageSubscription => 'Gestionar Suscripción';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get mealShowDetails => 'Mostrar detalles';

  @override
  String get mealHideDetails => 'Ocultar detalles';

  @override
  String get taxSimTitularesHint =>
      'Número de titulares de ingresos en el hogar';

  @override
  String get taxSimMealTypeHint =>
      'Tarjeta: exento de impuestos hasta el límite legal. Efectivo: tributado como ingreso.';

  @override
  String get taxSimIRSFull => 'IRPF (Impuesto sobre la Renta) retención';

  @override
  String get taxSimSSFull => 'SS (Seguridad Social)';

  @override
  String get stressZoneCritical =>
      '0–39: Alta presión financiera, acción urgente necesaria';

  @override
  String get stressZoneWarning =>
      '40–59: Algunos riesgos presentes, mejoras recomendadas';

  @override
  String get stressZoneGood =>
      '60–79: Finanzas saludables, pequeñas optimizaciones posibles';

  @override
  String get stressZoneExcellent =>
      '80–100: Posición financiera fuerte, bien gestionada';

  @override
  String get projectionStressHint =>
      'Cómo este escenario de gastos afecta tu puntuación general de salud financiera (0–100)';

  @override
  String get coachWelcomeTitle => 'Tu Coach Financiero IA';

  @override
  String get coachWelcomeBody =>
      'Pregunta sobre tu presupuesto, gastos o ahorros. El coach analiza tus datos financieros reales para darte consejos personalizados.';

  @override
  String get coachWelcomeCredits =>
      'Los créditos se usan en los modos Plus y Pro. El modo Eco es siempre gratuito.';

  @override
  String get coachWelcomeRateLimit =>
      'Para garantizar respuestas de calidad, hay una breve pausa entre mensajes.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Comprar créditos';

  @override
  String get coachContinueEco => 'Continuar con Eco';

  @override
  String get coachAchieved => 'Â¡Lo logré!';

  @override
  String get coachNotYet => 'Aún no';

  @override
  String coachCreditsAdded(int count) {
    return '+$count créditos añadidos';
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
  String get settingsSubscription => 'Suscripción';

  @override
  String get settingsSubscriptionFree => 'Gratuito';

  @override
  String settingsActiveCategoriesCount(int active, int total) {
    return 'Categorías Activas ($active de $total)';
  }

  @override
  String get settingsPausedCategories => 'Categorías Pausadas';

  @override
  String get settingsOpenDashboard => 'Abrir Dashboard Detallado';

  @override
  String get settingsAssistantGroup => 'ASISTENTE';

  @override
  String get settingsAiCoach => 'Coach IA';

  @override
  String get setupWizardSubsidyLabel => 'SUBSIDIOS';

  @override
  String get setupWizardPerDay => '/día';

  @override
  String get configurationError => 'Error de Configuración';

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
      'Gráfico de tendencias de gastos mostrando presupuesto versus gastos reales';

  @override
  String get customCategories => 'Categorías';

  @override
  String get customCategoryAdd => 'Añadir Categoría';

  @override
  String get customCategoryEdit => 'Editar Categoría';

  @override
  String get customCategoryDelete => 'Eliminar Categoría';

  @override
  String get customCategoryDeleteConfirm => 'Â¿Eliminar esta categoría?';

  @override
  String get customCategoryName => 'Nombre de categoría';

  @override
  String get customCategoryIcon => 'Icono';

  @override
  String get customCategoryColor => 'Color';

  @override
  String get customCategoryEmpty => 'Sin categorías personalizadas';

  @override
  String get customCategorySaved => 'Categoría guardada';

  @override
  String get customCategoryInUse => 'Categoría en uso, no se puede eliminar';

  @override
  String get customCategoryPredefinedHint =>
      'Categorías predefinidas usadas en toda la aplicación';

  @override
  String get customCategoryDefault => 'Predefinida';

  @override
  String get expenseLocationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String get expenseAttachPhoto => 'Adjuntar Foto';

  @override
  String get expenseAttachCamera => 'Cámara';

  @override
  String get expenseAttachGallery => 'Galería';

  @override
  String get expenseAttachUploadFailed =>
      'Error al subir anexos. Verifique su conexión.';

  @override
  String get expenseReceiptsLabel => 'Recibos';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Detectar ubicación';

  @override
  String get biometricLockTitle => 'Bloqueo de App';

  @override
  String get biometricLockSubtitle =>
      'Requerir autenticación al abrir la aplicación';

  @override
  String get biometricPrompt => 'Autentícate para continuar';

  @override
  String get biometricReason =>
      'Verifica tu identidad para desbloquear la aplicación';

  @override
  String get biometricRetry => 'Intentar de Nuevo';

  @override
  String get notifDailyExpenseReminder => 'Recordatorio diario de gastos';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Te recuerda registrar los gastos del día';

  @override
  String get notifDailyExpenseTitle => 'Â¡No olvides tus gastos!';

  @override
  String get notifDailyExpenseBody =>
      'Tómate un momento para registrar los gastos de hoy';

  @override
  String get settingsSalaryLabelHint => 'ej: Empleo principal, Freelance';

  @override
  String get settingsExpenseNameLabel => 'NOMBRE DEL GASTO';

  @override
  String get settingsCategoryLabel => 'CATEGORÍA';

  @override
  String get settingsMonthlyBudgetLabel => 'PRESUPUESTO MENSUAL';

  @override
  String get expenseLocationSearch => 'Buscar';

  @override
  String get expenseLocationSearchHint => 'Buscar dirección...';

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
  String get dashboardBurnRateDailyAvg => 'MEDIA/DÍA';

  @override
  String get dashboardBurnRateAllowance => 'DISP./DÍA';

  @override
  String get dashboardBurnRateDaysLeft => 'DÍAS RESTANTES';

  @override
  String get dashboardTopCategoriesTitle => 'Top Categorías';

  @override
  String get dashboardTopCategoriesSubtitle =>
      'Categorías con más gastos este mes';

  @override
  String get dashboardCashFlowTitle => 'Previsión de Flujo';

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
      'Tu tasa de ahorro está por debajo del 10%. Identifica un gasto que puedas reducir este mes.';

  @override
  String get dashboardCoachHighSpending =>
      'Los gastos se acercan a tus ingresos. Revisa los gastos no esenciales.';

  @override
  String get dashboardCoachGoodSavings =>
      'Â¡Excelente! Estás ahorrando más del 20%. Â¡Sigue así!';

  @override
  String get dashboardCoachGeneral =>
      'Toca para obtener análisis personalizados de tu presupuesto.';

  @override
  String get dashGroupInsights => 'Análisis';

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
  String get mealPlanUndoMessage => 'Plan regenerado con éxito';

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
  String get nutritionDashboardTitle => 'Nutrición Semanal';

  @override
  String get nutritionCalories => 'Calorías';

  @override
  String get nutritionProtein => 'Proteína';

  @override
  String get nutritionCarbs => 'Carbohidratos';

  @override
  String get nutritionFat => 'Grasa';

  @override
  String get nutritionFiber => 'Fibra';

  @override
  String get nutritionTopProteins => 'Top proteínas';

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

  @override
  String groceryStorePartialFallback(String storeName) {
    return '$storeName tiene datos parciales — los precios pueden estar desactualizados';
  }

  @override
  String groceryStoreFailedFallback(String storeName) {
    return '$storeName no disponible — excluida de las comparaciones';
  }

  @override
  String get groceryStoreFreshLabel => 'Actualizado';

  @override
  String get groceryStoreStaleLabel => 'Desactualizado';

  @override
  String get groceryStorePartialLabel => 'Parcial';

  @override
  String get groceryStoreFailedLabel => 'No disponible';

  @override
  String groceryStoreUpdatedHoursAgo(int hours) {
    return 'Actualizado hace ${hours}h';
  }

  @override
  String groceryStoreUpdatedDaysAgo(int days) {
    return 'Actualizado hace ${days}d';
  }

  @override
  String get upgradeToPro => 'Mejorar a Pro';

  @override
  String get createAsPaused => 'Crear como pausado';

  @override
  String get categoryLimitReached => 'Límite de categorías alcanzado';

  @override
  String get savingsGoalLimitReached =>
      'Límite de objetivos de ahorro alcanzado';

  @override
  String get limitSwapActive => 'Intercambiar activa';

  @override
  String get limitChooseActiveGoal => 'Elegir objetivo activo';

  @override
  String get errorBoundarySomethingWentWrong => 'Algo salió mal';

  @override
  String get errorBoundaryDescription =>
      'Esta sección encontró un error.\nEl resto de la app no se ve afectada.';

  @override
  String get retry => 'Reintentar';

  @override
  String get filter => 'Filtro';

  @override
  String get paywallFree => 'Gratis';

  @override
  String get paywallStartPro => 'Iniciar Pro';

  @override
  String get paywallBestValue => 'Mejor valor';

  @override
  String get complexityEasy => 'Fácil';

  @override
  String get complexityPro => 'Pro';

  @override
  String get spendingAnomalyTitle => 'Anomalías de Gastos';

  @override
  String get spendingAnomalyInfo =>
      'Categorías donde el gasto actual se desvía más del 30% del promedio de los últimos 3 meses.';

  @override
  String spendingAnomalyAvg(String amount) {
    return 'Prom: $amount';
  }

  @override
  String get rolloverToggleLabel => 'Transferencia';

  @override
  String get rolloverHelperText =>
      'Transferir presupuesto no gastado o excedido al próximo mes';

  @override
  String get settingsDashSpendingAnomalies => 'Anomalias de gasto';

  @override
  String get subtitleShowSpendingAnomalies =>
      'Destaca categorias que se desvian de los patrones de gasto recientes';

  @override
  String get yearlySummaryTitle => 'Resumen Anual';

  @override
  String get yearlySummaryIncome => 'Ingresos Totales';

  @override
  String get yearlySummaryExpenses => 'Gastos Totales';

  @override
  String get yearlySummaryNetSavings => 'Ahorro Neto';

  @override
  String yearlySummarySavingsRate(String rate) {
    return 'Tasa de ahorro: $rate%';
  }

  @override
  String get yearlySummaryHighlights => 'Destacados';

  @override
  String yearlySummaryBestMonth(String month) {
    return 'Mejor mes ($month)';
  }

  @override
  String yearlySummaryWorstMonth(String month) {
    return 'Peor mes ($month)';
  }

  @override
  String get yearlySummaryCategoryBreakdown => 'Desglose por Categoria';

  @override
  String get mealSectionHousehold => 'Quien come?';

  @override
  String get mealSectionHouseholdSub => 'Hogar y miembros';

  @override
  String get mealSectionGoals => 'Objetivo';

  @override
  String get mealSectionGoalsSub => 'Planificacion y comidas activas';

  @override
  String get mealSectionEatingOut => 'Comer fuera';

  @override
  String get mealSectionEatingOutSub => 'Dias fuera y dias vegetarianos';

  @override
  String get mealSectionDietary => 'Restricciones alimentarias';

  @override
  String get mealSectionDietarySub => 'Alergias, intolerancias y preferencias';

  @override
  String get mealSectionPrep => 'Preparacion';

  @override
  String get mealSectionPrepSub => 'Tiempo, complejidad y equipamiento';

  @override
  String get mealSectionStrategies => 'Estrategias';

  @override
  String get mealSectionStrategiesSub => 'Eficiencia, costes y aprovechamiento';

  @override
  String get mealSectionProtein => 'Variedad de proteina';

  @override
  String get mealSectionProteinSub => 'Pescado, legumbres y carne roja';

  @override
  String get mealSectionNutrition => 'Nutricion y salud';

  @override
  String get mealSectionNutritionSub =>
      'Calorias, proteina, fibra y condiciones medicas';

  @override
  String get mealSectionPantry => 'Despensa';

  @override
  String get mealSectionPantrySub => 'Ingredientes base, semanales y generales';

  @override
  String get complexityMedium => 'Medio';

  @override
  String get coachDowngradeTitle => 'Modo cambiado a Eco';

  @override
  String get coachCompareWithPlus => 'Con Plus';

  @override
  String get coachCompareMemory20 => 'Memoria: 20 msgs';

  @override
  String get coachCompareDetailedReplies => 'Respuestas detalladas';

  @override
  String get coachCompareFinancialContext => 'Contexto financiero';

  @override
  String get coachCompareWithEco => 'Con Eco';

  @override
  String get coachCompareMemory6 => 'Memoria: 6 msgs';

  @override
  String get coachCompareShortReplies => 'Respuestas cortas';

  @override
  String get coachCompareLimitedContext => 'Contexto limitado';

  @override
  String coachEndowmentBanner(int remaining) {
    return 'Estas usando el modo Plus gratis — el coach recuerda los ultimos 20 mensajes ($remaining restantes)';
  }

  @override
  String coachRecommendPro(int cost) {
    return 'Pregunta compleja detectada — Pro daria un analisis mas detallado ($cost cr.)';
  }

  @override
  String coachRecommendPlus(int cost) {
    return 'Plus ofrece mas contexto para este analisis ($cost cr.)';
  }

  @override
  String get coachNextStep => 'PROXIMO PASO';

  @override
  String get coachPendingAction => 'Accion pendiente de la ultima sesion';

  @override
  String coachSuggestedDaysAgo(int daysAgo) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAgo,
      locale: localeName,
      other: 'dias',
      one: 'dia',
    );
    return 'Sugerido hace $daysAgo $_temp0';
  }

  @override
  String get coachCapWarning =>
      'Maximo alcanzado (150). Usa tus creditos antes de la proxima renovacion!';

  @override
  String coachPackSessions(int plus, int pro) {
    return '$plus consultas Plus o $pro consultas Pro';
  }

  @override
  String get coachCreditsTitle => 'Creditos AI Coach';

  @override
  String coachCreditsRemaining(int count) {
    return '$count restantes';
  }

  @override
  String get coachRoiInsightPrefix => 'En la ultima sesion Pro, discutimos ';

  @override
  String get coachRoiPotential => '. Potencial: ';

  @override
  String get coachRoiCost => '. Costo 5 creditos (€0,05).';

  @override
  String coachCapWarningSheet(int max) {
    return 'Maximo alcanzado ($max). Usa los creditos antes de comprar mas.';
  }

  @override
  String get coachCreditsLabel => 'creditos';

  @override
  String get coachBestValue => 'MEJOR VALOR';

  @override
  String coachWastedCredits(int wasted) {
    return 'Perderias $wasted creditos';
  }

  @override
  String coachRecommendedPack(int credits) {
    return 'Recomendamos el paquete de $credits creditos';
  }

  @override
  String cmdInvalidAction(String action) {
    return 'Accion o parametros invalidos: $action';
  }

  @override
  String cmdUnknownAction(String action) {
    return 'Accion desconocida: $action';
  }

  @override
  String cmdExpenseAdded(String amount, String category) {
    return 'Gasto anadido: $amount en $category';
  }

  @override
  String cmdShoppingItemAdded(String name) {
    return 'Articulo anadido: $name';
  }

  @override
  String cmdSavingsGoalAdded(String name) {
    return 'Objetivo de ahorro anadido: $name';
  }

  @override
  String cmdRecurringExpenseAdded(String amount, String category) {
    return 'Gasto recurrente anadido: $amount en $category';
  }

  @override
  String cmdShoppingItemNotFound(String name) {
    return 'Articulo no encontrado: $name';
  }

  @override
  String cmdShoppingItemRemoved(String name) {
    return 'Articulo eliminado: $name';
  }

  @override
  String cmdSavingsGoalNotFound(String name) {
    return 'Objetivo de ahorro no encontrado: $name';
  }

  @override
  String cmdContributionAdded(String amount, String name) {
    return 'Contribucion anadida: $amount a $name';
  }

  @override
  String cmdShoppingItemChecked(String name) {
    return 'Articulo marcado: $name';
  }

  @override
  String cmdShoppingItemUnchecked(String name) {
    return 'Articulo desmarcado: $name';
  }

  @override
  String cmdExpenseNotFound(String description) {
    return 'Gasto no encontrado: $description';
  }

  @override
  String cmdExpenseDeleted(String description) {
    return 'Gasto eliminado: $description';
  }

  @override
  String cmdThemeSet(String mode) {
    return 'Tema configurado a $mode';
  }

  @override
  String cmdPaletteSet(String palette) {
    return 'Paleta de colores configurada a $palette';
  }

  @override
  String cmdLanguageSet(String locale) {
    return 'Idioma configurado a $locale';
  }

  @override
  String cmdNavigatedTo(String screen) {
    return 'Navegado a $screen';
  }

  @override
  String get cmdCheckedItemsCleared => 'Articulos marcados limpiados';

  @override
  String get cmdParseError =>
      'Lo siento, no pude entender tu solicitud. Intenta reformularla.';

  @override
  String get cmdHelpOutput =>
      'Comandos disponibles:\n- Anadir gasto: anade [cantidad] en [categoria]\n- Lista de compras: anade [articulo] a la lista de compras\n- Quitar de la lista: quita [articulo] de la lista de compras\n- Marcar articulo: marca [articulo] en la lista de compras\n- Objetivo de ahorro: crea objetivo de ahorro [nombre] de [cantidad]\n- Anadir al objetivo: anade [cantidad] al objetivo [nombre]\n- Gasto recurrente: anade gasto recurrente [cantidad] en [categoria]\n- Eliminar gasto: elimina el gasto [descripcion]\n- Tema: tema [claro/oscuro/sistema]\n- Paleta: color [ocean/emerald/violet/teal/sunset]\n- Idioma: lengua [ingles/portugues/espanol/frances]\n- Navegar: abre [pantalla]\n- Limpiar marcados: limpiar los marcados\n- Ayuda: ayuda';

  @override
  String get coachOfflineBanner =>
      'Sin conexion. El coach de IA requiere conexion a internet.';

  @override
  String get coachOfflineSendDisabled =>
      'Enviar esta desactivado mientras no hay conexion.';

  @override
  String get cmdOfflineBanner =>
      'Sin conexion. Solo los comandos locales (tema, navegacion) funcionan.';

  @override
  String get cmdOfflineBlocked =>
      'Este comando requiere conexion a internet. Prueba un comando local como cambiar el tema o navegar.';

  @override
  String coachFreeTrialRemaining(int count) {
    return '$count pregunta(s) gratuita(s) restante(s) este mes';
  }

  @override
  String get coachFreeTrialExhausted =>
      'Has agotado tus preguntas gratuitas este mes. Actualiza para seguir usando el AI Coach.';

  @override
  String get coachFreeTrialUpgrade => 'Actualizar para coaching ilimitado';

  @override
  String coachFreeTrialBanner(int used, int total) {
    return 'Prueba gratuita: $used/$total preguntas usadas este mes';
  }

  @override
  String get mealCourseSoupStarter => 'Sopa / Entrada';

  @override
  String get mealCourseMain => 'Plato Principal';

  @override
  String get mealCourseDessert => 'Postre';

  @override
  String get mealSubstituteHint =>
      'Toca un ingrediente para sustituirlo por otro';

  @override
  String get mealSubstituteSameCategory => 'Misma categoria';

  @override
  String get mealSubstituteOtherCategories => 'Otras categorias';

  @override
  String get wizardCourseStructure => 'Estructura de la comida';

  @override
  String get wizardIncludeSoupStarter => 'Incluir sopa o entrada';

  @override
  String get wizardSoupStarterHint =>
      'Anade una sopa o entrada como primer plato';

  @override
  String get wizardIncludeDessert => 'Incluir postre';

  @override
  String get wizardDessertHint =>
      'Anade fruta, dulce u otro postre como ultimo plato';
}
