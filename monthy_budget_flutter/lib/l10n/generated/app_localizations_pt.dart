// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get navBudget => 'OrÃ§amento';

  @override
  String get navGrocery => 'Supermercado';

  @override
  String get navList => 'Lista';

  @override
  String get navCoach => 'Coach';

  @override
  String get navMeals => 'RefeiÃ§Ãµes';

  @override
  String get navBudgetTooltip => 'Resumo do orÃ§amento mensal';

  @override
  String get navGroceryTooltip => 'CatÃ¡logo de produtos';

  @override
  String get navListTooltip => 'Lista de compras';

  @override
  String get navCoachTooltip => 'Coach financeiro com IA';

  @override
  String get navMealsTooltip => 'Planeador de refeiÃ§Ãµes';

  @override
  String get appTitle => 'OrÃ§amento Mensal';

  @override
  String get loading => 'A carregar...';

  @override
  String get loadingApp => 'A carregar a aplicaÃ§Ã£o';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get clear => 'Limpar';

  @override
  String errorSavingPurchase(String error) {
    return 'Erro ao guardar compra: $error';
  }

  @override
  String filterBy(String label) {
    return 'Filtrar por $label';
  }

  @override
  String addToList(String name) {
    return 'Adicionar $name Ã  lista';
  }

  @override
  String get enumMaritalSolteiro => 'Solteiro(a)';

  @override
  String get enumMaritalCasado => 'Casado(a)';

  @override
  String get enumMaritalUniaoFacto => 'Uniao de Facto';

  @override
  String get enumMaritalDivorciado => 'Divorciado(a)';

  @override
  String get enumMaritalViuvo => 'Viuvo(a)';

  @override
  String get enumSubsidyNone => 'Sem duodÃ©cimos';

  @override
  String get enumSubsidyFull => 'Com duodÃ©cimos';

  @override
  String get enumSubsidyHalf => '50% duodÃ©cimos';

  @override
  String get enumSubsidyNoneShort => 'Sem';

  @override
  String get enumSubsidyFullShort => 'Com';

  @override
  String get enumSubsidyHalfShort => '50%';

  @override
  String get enumMealAllowanceNone => 'Sem';

  @override
  String get enumMealAllowanceCard => 'Cartao';

  @override
  String get enumMealAllowanceCash => 'Com base';

  @override
  String get enumCatTelecomunicacoes => 'TelecomunicaÃ§Ãµes';

  @override
  String get enumCatEnergia => 'Energia';

  @override
  String get enumCatAgua => 'Ãgua';

  @override
  String get enumCatAlimentacao => 'AlimentaÃ§Ã£o';

  @override
  String get enumCatEducacao => 'EducaÃ§Ã£o';

  @override
  String get enumCatHabitacao => 'HabitaÃ§Ã£o';

  @override
  String get enumCatTransportes => 'Transportes';

  @override
  String get enumCatSaude => 'SaÃºde';

  @override
  String get enumCatLazer => 'Lazer';

  @override
  String get enumCatOutros => 'Outros';

  @override
  String get enumChartExpensesPie => 'Despesas por Categoria';

  @override
  String get enumChartIncomeVsExpenses => 'Rendimento vs Despesas';

  @override
  String get enumChartNetIncome => 'Rendimento LÃ­quido';

  @override
  String get enumChartDeductions => 'Descontos (IRS + SS)';

  @override
  String get enumChartSavingsRate => 'Taxa de PoupanÃ§a';

  @override
  String get enumMealBreakfast => 'Pequeno-almoÃ§o';

  @override
  String get enumMealLunch => 'AlmoÃ§o';

  @override
  String get enumMealSnack => 'Lanche';

  @override
  String get enumMealDinner => 'Jantar';

  @override
  String get enumObjMinimizeCost => 'Minimizar custo';

  @override
  String get enumObjBalancedHealth => 'EquilÃ­brio custo/saÃºde';

  @override
  String get enumObjHighProtein => 'Alta proteÃ­na';

  @override
  String get enumObjLowCarb => 'Baixo carboidrato';

  @override
  String get enumObjVegetarian => 'Vegetariano';

  @override
  String get enumEquipOven => 'Forno';

  @override
  String get enumEquipAirFryer => 'Air Fryer';

  @override
  String get enumEquipFoodProcessor => 'Robot de cozinha';

  @override
  String get enumEquipPressureCooker => 'Panela de pressÃ£o';

  @override
  String get enumEquipMicrowave => 'Micro-ondas';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'Sem restriÃ§Ã£o';

  @override
  String get enumSodiumReduced => 'SÃ³dio reduzido';

  @override
  String get enumSodiumLow => 'Baixo sÃ³dio';

  @override
  String get enumAge0to3 => '0â€“3 anos';

  @override
  String get enumAge4to10 => '4â€“10 anos';

  @override
  String get enumAgeTeen => 'Adolescente';

  @override
  String get enumAgeAdult => 'Adulto';

  @override
  String get enumAgeSenior => 'SÃ©nior (65+)';

  @override
  String get enumActivitySedentary => 'SedentÃ¡rio';

  @override
  String get enumActivityModerate => 'Moderado';

  @override
  String get enumActivityActive => 'Ativo';

  @override
  String get enumActivityVeryActive => 'Muito ativo';

  @override
  String get enumMedDiabetes => 'Diabetes';

  @override
  String get enumMedHypertension => 'HipertensÃ£o';

  @override
  String get enumMedHighCholesterol => 'Colesterol alto';

  @override
  String get enumMedGout => 'Gota';

  @override
  String get enumMedIbs => 'SÃ­ndrome do intestino irritÃ¡vel';

  @override
  String get stressExcellent => 'Excelente';

  @override
  String get stressGood => 'Bom';

  @override
  String get stressWarning => 'AtenÃ§Ã£o';

  @override
  String get stressCritical => 'CrÃ­tico';

  @override
  String get stressFactorSavings => 'Taxa de poupanÃ§a';

  @override
  String get stressFactorSafety => 'Margem de seguranÃ§a';

  @override
  String get stressFactorFood => 'OrÃ§amento alimentaÃ§Ã£o';

  @override
  String get stressFactorStability => 'Estabilidade despesas';

  @override
  String get stressStable => 'EstÃ¡vel';

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
    return 'AlimentaÃ§Ã£o excedeu o orÃ§amento em $percent% â€” considere rever porÃ§Ãµes ou frequÃªncia de compras.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Despesas reais superaram o planeado em $amountâ‚¬ â€” ajustar valores nas definiÃ§Ãµes?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Poupou $amountâ‚¬ mais do que previsto â€” pode reforÃ§ar fundo de emergÃªncia.';
  }

  @override
  String get monthReviewOnTrack =>
      'Despesas dentro do previsto. Bom controlo orÃ§amental.';

  @override
  String get dashboardTitle => 'OrÃ§amento Mensal';

  @override
  String get dashboardViewFullReport => 'Ver RelatÃ³rio Completo';

  @override
  String get dashboardStressIndex => 'Ãndice de Tranquilidade';

  @override
  String get dashboardTension => 'TensÃ£o';

  @override
  String get dashboardLiquidity => 'Liquidez';

  @override
  String get dashboardFinalPosition => 'PosiÃ§Ã£o Final';

  @override
  String get dashboardMonth => 'MÃªs';

  @override
  String get dashboardGross => 'Bruto';

  @override
  String get dashboardNet => 'LÃ­quido';

  @override
  String get dashboardExpenses => 'Despesas';

  @override
  String get dashboardSavingsRate => 'Taxa PoupanÃ§a';

  @override
  String get dashboardViewTrends => 'Ver evoluÃ§Ã£o';

  @override
  String get dashboardViewProjection => 'Ver projeÃ§Ã£o';

  @override
  String get dashboardFinancialSummary => 'RESUMO FINANCEIRO';

  @override
  String get dashboardOpenSettings => 'Abrir definiÃ§Ãµes';

  @override
  String get dashboardMonthlyLiquidity => 'LIQUIDEZ MENSAL';

  @override
  String get dashboardPositiveBalance => 'Saldo positivo';

  @override
  String get dashboardNegativeBalance => 'Saldo negativo';

  @override
  String dashboardHeroLabel(String amount, String status) {
    return 'Liquidez mensal: $amount, $status';
  }

  @override
  String get dashboardConfigureData =>
      'Configure os seus dados para ver o resumo.';

  @override
  String get dashboardOpenSettingsButton => 'Abrir DefiniÃ§Ãµes';

  @override
  String get dashboardGrossIncome => 'Rendimento Bruto';

  @override
  String get dashboardNetIncome => 'Rendimento LÃ­quido';

  @override
  String dashboardInclMealAllowance(String amount) {
    return 'Incl. sub. alim.: $amount';
  }

  @override
  String get dashboardDeductions => 'Descontos';

  @override
  String dashboardIrsSs(String irs, String ss) {
    return 'IRS: $irs | SS: $ss';
  }

  @override
  String dashboardExpensesAmount(String amount) {
    return 'Despesas: $amount';
  }

  @override
  String get dashboardSalaryDetail => 'DETALHE VENCIMENTOS';

  @override
  String dashboardSalaryN(int n) {
    return 'Vencimento $n';
  }

  @override
  String get dashboardFood => 'ALIMENTAÃ‡ÃƒO';

  @override
  String get dashboardSimulate => 'Simular';

  @override
  String get dashboardBudgeted => 'OrÃ§ado';

  @override
  String get dashboardSpent => 'Gasto';

  @override
  String get dashboardRemaining => 'Restante';

  @override
  String get dashboardFinalizePurchaseHint =>
      'Finaliza uma compra na Lista para registar gastos.';

  @override
  String get dashboardPurchaseHistory => 'HISTÃ“RICO DE COMPRAS';

  @override
  String get dashboardViewAll => 'Ver tudo';

  @override
  String get dashboardAllPurchases => 'Todas as Compras';

  @override
  String dashboardPurchaseLabel(String date, String amount) {
    return 'Compra de $date, $amount';
  }

  @override
  String dashboardProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '1 produto',
    );
    return '$_temp0';
  }

  @override
  String get dashboardMonthlyExpenses => 'DESPESAS MENSAIS';

  @override
  String get dashboardTotal => 'Total';

  @override
  String get dashboardGrossWithSubsidy => 'Bruto c/ duodÃ©c.';

  @override
  String dashboardIrsRate(String rate) {
    return 'IRS ($rate)';
  }

  @override
  String get dashboardSsRate => 'SS (11%)';

  @override
  String get dashboardMealAllowance => 'Sub. AlimentaÃ§Ã£o';

  @override
  String get dashboardExemptIncome => 'Rend. Isento';

  @override
  String get dashboardDetails => 'Detalhes';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs mÃªs passado';
  }

  @override
  String get dashboardPaceWarning => 'A gastar mais rÃ¡pido que o previsto';

  @override
  String get dashboardPaceCritical =>
      'Risco de ultrapassar orÃ§amento alimentar';

  @override
  String get dashboardPace => 'Ritmo';

  @override
  String get dashboardProjection => 'ProjeÃ§Ã£o';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actualâ‚¬/dia vs $expectedâ‚¬/dia';
  }

  @override
  String get dashboardSummaryLabel => 'â€” RESUMO';

  @override
  String get dashboardViewMonthSummary => 'Ver resumo do mÃªs';

  @override
  String get coachTitle => 'Coach Financeiro';

  @override
  String get coachSubtitle => 'IA Â· GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Adiciona a tua OpenAI API key nas DefiniÃ§Ãµes para usar esta funcionalidade.';

  @override
  String get coachAnalysisTitle => 'AnÃ¡lise financeira em 3 partes';

  @override
  String get coachAnalysisDescription =>
      'Posicionamento geral Â· Factores crÃ­ticos do Ãndice de Tranquilidade Â· Oportunidade imediata. Baseado nos teus dados reais de orÃ§amento, despesas e histÃ³rico de compras.';

  @override
  String get coachConfigureApiKey => 'Configurar API key nas DefiniÃ§Ãµes';

  @override
  String get coachApiKeyConfigured => 'API key configurada';

  @override
  String get coachAnalyzeButton => 'Analisar o meu orÃ§amento';

  @override
  String get coachAnalyzing => 'A analisar...';

  @override
  String get coachCustomAnalysis => 'AnÃ¡lise personalizada';

  @override
  String get coachNewAnalysis => 'Gerar nova anÃ¡lise';

  @override
  String get coachHistory => 'HISTÃ“RICO';

  @override
  String get coachClearAll => 'Limpar tudo';

  @override
  String get coachClearTitle => 'Limpar histÃ³rico';

  @override
  String get coachClearContent =>
      'Tens a certeza que queres apagar todas as anÃ¡lises guardadas?';

  @override
  String get coachDeleteLabel => 'Eliminar anÃ¡lise';

  @override
  String get coachDeleteTooltip => 'Eliminar';

  @override
  String get coachEmptyTitle => 'O teu coach financeiro';

  @override
  String get coachEmptyBody =>
      'Pergunta o que quiseres sobre o teu orcamento, despesas ou poupancas. Vou usar os teus dados reais para dar conselhos personalizados.';

  @override
  String get coachQuickPrompt1 => 'Onde posso cortar despesas este mes?';

  @override
  String get coachQuickPrompt2 => 'Como melhoro a minha poupanca?';

  @override
  String get coachQuickPrompt3 => 'Ajuda-me a definir um plano para 30 dias.';

  @override
  String get coachComposerHint => 'Pergunta ao coach...';

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
  String get coachCostFree => 'Modo Eco â€” sem custos de creditos.';

  @override
  String coachCostCredits(int cost) {
    return 'Esta mensagem custa $cost creditos.';
  }

  @override
  String get coachFree => 'Gratis';

  @override
  String coachPerMsg(int cost) {
    return '$cost/msg';
  }

  @override
  String get coachEcoFallbackTitle => 'Modo Eco ativo (sem creditos)';

  @override
  String get coachEcoFallbackBody =>
      'Podes continuar a conversar, mas com memoria reduzida.';

  @override
  String get coachRestoreMemory => 'Restaurar memoria';

  @override
  String get cmdAssistantTitle => 'Assistente';

  @override
  String get cmdAssistantHint => 'O que precisas?';

  @override
  String get cmdAssistantTooltip => 'Precisa de ajuda? Toca aqui';

  @override
  String get cmdSuggestionAddExpense => 'Adicionar despesa';

  @override
  String get cmdSuggestionOpenList => 'Abrir lista de compras';

  @override
  String get cmdSuggestionChangeTheme => 'Mudar tema';

  @override
  String get cmdSuggestionOpenSettings => 'Ir para definicoes';

  @override
  String get cmdTemplateAddExpense => 'Adiciona [valor] euros em [categoria]';

  @override
  String get cmdTemplateChangeTheme => 'Muda o tema para [claro/escuro]';

  @override
  String get cmdExecutionFailed =>
      'Percebi o pedido, mas nao consegui executar. Tenta novamente.';

  @override
  String get cmdNotUnderstood => 'Nao percebi. Podes reformular?';

  @override
  String get cmdUndo => 'Desfazer';

  @override
  String get expenseDeleted => 'Despesa eliminada';

  @override
  String get cmdCapabilitiesCta => 'O que posso fazer?';

  @override
  String get cmdCapabilitiesTitle => 'Acoes disponiveis';

  @override
  String get cmdCapabilitiesSubtitle =>
      'Estas sao as acoes que o assistente suporta neste momento.';

  @override
  String get cmdCapabilitiesFooter =>
      'Estamos a adicionar mais. Se ainda nao estiver aqui, pode nao funcionar.';

  @override
  String get cmdCapabilityAddExpense => 'Adicionar uma despesa';

  @override
  String get cmdCapabilityAddExpenseExample =>
      'Adiciona [valor] euros em [categoria]';

  @override
  String get cmdCapabilityAddShoppingItem => 'Adicionar item a lista';

  @override
  String get cmdCapabilityAddShoppingItemExample =>
      'Adiciona [item] a lista de compras';

  @override
  String get cmdCapabilityRemoveShoppingItem => 'Remover item da lista';

  @override
  String get cmdCapabilityRemoveShoppingItemExample =>
      'Remove [item] da lista de compras';

  @override
  String get cmdCapabilityToggleShoppingItemChecked =>
      'Marcar ou desmarcar item da lista';

  @override
  String get cmdCapabilityToggleShoppingItemCheckedExample =>
      'Marca [item] na lista de compras';

  @override
  String get cmdCapabilityAddSavingsGoal => 'Criar objetivo de poupanca';

  @override
  String get cmdCapabilityAddSavingsGoalExample =>
      'Cria objetivo de poupanca [nome] de [valor]';

  @override
  String get cmdCapabilityAddSavingsContribution =>
      'Adicionar ao objetivo de poupanca';

  @override
  String get cmdCapabilityAddSavingsContributionExample =>
      'Adiciona [valor] ao objetivo [nome]';

  @override
  String get cmdCapabilityAddRecurringExpense => 'Adicionar despesa recorrente';

  @override
  String get cmdCapabilityAddRecurringExpenseExample =>
      'Adiciona despesa recorrente [valor] em [categoria] dia [dia]';

  @override
  String get cmdCapabilityDeleteExpense => 'Apagar uma despesa';

  @override
  String get cmdCapabilityDeleteExpenseExample => 'Apaga a despesa [descricao]';

  @override
  String get cmdCapabilityChangeTheme => 'Mudar tema';

  @override
  String get cmdCapabilityChangeThemeExample =>
      'Muda o tema para [claro/escuro]';

  @override
  String get cmdCapabilityChangePalette => 'Mudar paleta de cor';

  @override
  String get cmdCapabilityChangePaletteExample =>
      'Cor [ocean/emerald/violet/teal/sunset]';

  @override
  String get cmdCapabilityChangeLanguage => 'Mudar idioma';

  @override
  String get cmdCapabilityChangeLanguageExample =>
      'Idioma [ingles/portugues/espanhol/frances]';

  @override
  String get cmdCapabilityNavigate => 'Abrir ecra';

  @override
  String get cmdCapabilityNavigateExample => 'Abre a lista de compras';

  @override
  String get cmdCapabilityClearChecked => 'Limpar itens marcados';

  @override
  String get cmdCapabilityClearCheckedExample => 'Limpa os itens marcados';

  @override
  String get groceryTitle => 'Supermercado';

  @override
  String get grocerySearchHint => 'Pesquisar produto...';

  @override
  String get groceryLoadingLabel => 'A carregar produtos';

  @override
  String get groceryLoadingMessage => 'A carregar produtos...';

  @override
  String get groceryAll => 'Todos';

  @override
  String groceryProductCount(int count) {
    return '$count produtos';
  }

  @override
  String groceryAddedToList(String name) {
    return '$name adicionado Ã  lista';
  }

  @override
  String groceryAvgPrice(String unit) {
    return '$unit Â· preÃ§o mÃ©dio';
  }

  @override
  String get groceryAvailabilityTitle => 'Disponibilidade dos dados';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Mercado: $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh frescas Â· $partial parciais Â· $failed indisponÃ­veis';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Algumas lojas tÃªm dados parciais ou desatualizados. As comparaÃ§Ãµes podem estar incompletas.';

  @override
  String get groceryEmptyStateTitle => 'Sem dados de supermercado disponÃ­veis';

  @override
  String get groceryEmptyStateMessage =>
      'Tenta novamente mais tarde ou muda de mercado nas definiÃ§Ãµes.';

  @override
  String get shoppingTitle => 'Lista de Compras';

  @override
  String get shoppingEmpty => 'Lista vazia';

  @override
  String get shoppingEmptyMessage =>
      'Adiciona produtos a partir do\necrÃ£ Supermercado.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count por comprar Â· $total';
  }

  @override
  String get shoppingClear => 'Limpar';

  @override
  String get shoppingFinalize => 'Finalizar Compra';

  @override
  String get shoppingEstimatedTotal => 'Total estimado';

  @override
  String get shoppingHowMuchSpent => 'QUANTO GASTEI NO TOTAL? (opcional)';

  @override
  String get shoppingConfirm => 'Confirmar';

  @override
  String get shoppingHistoryTooltip => 'HistÃ³rico de compras';

  @override
  String get shoppingHistoryTitle => 'HistÃ³rico de Compras';

  @override
  String shoppingItemChecked(String name) {
    return '$name, comprado';
  }

  @override
  String shoppingItemSwipe(String name) {
    return '$name, deslizar para remover';
  }

  @override
  String shoppingProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produtos',
      one: '1 produto',
    );
    return '$_temp0';
  }

  @override
  String get shoppingPendingSync => 'Sincronização pendente';

  @override
  String get shoppingViewItems => 'Itens';

  @override
  String get shoppingViewMeals => 'Refeicoes';

  @override
  String get shoppingViewStores => 'Lojas';

  @override
  String get offlineBannerMessage =>
      'Modo offline: as alterações serão sincronizadas assim que recuperar a ligação.';

  @override
  String get shoppingGroupOther => 'Outros';

  @override
  String shoppingGroupCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String shoppingCheapestAt(String store, String price) {
    return 'Mais barato em $store ($price)';
  }

  @override
  String get authLogin => 'Entrar na conta';

  @override
  String get authRegister => 'Criar conta';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'exemplo@email.com';

  @override
  String get authPassword => 'Palavra-passe';

  @override
  String get authLoginButton => 'Entrar';

  @override
  String get authRegisterButton => 'Registar';

  @override
  String get authSwitchToRegister => 'Criar conta nova';

  @override
  String get authSwitchToLogin => 'JÃ¡ tenho conta';

  @override
  String get authRegistrationSuccess =>
      'Conta criada! Verifique o seu email para confirmar a conta antes de iniciar sessÃ£o.';

  @override
  String get authErrorNetwork =>
      'NÃ£o foi possÃ­vel ligar ao servidor. Verifique a sua ligaÃ§Ã£o Ã  internet e tente novamente.';

  @override
  String get authErrorInvalidCredentials =>
      'Email ou palavra-passe invÃ¡lidos. Tente novamente.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Verifique o seu email antes de iniciar sessÃ£o.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiadas tentativas. Aguarde um momento e tente novamente.';

  @override
  String get authErrorGeneric => 'Ocorreu um erro. Tente novamente mais tarde.';

  @override
  String get householdSetupTitle => 'Configurar Agregado';

  @override
  String get householdCreate => 'Criar';

  @override
  String get householdJoinWithCode => 'Entrar com cÃ³digo';

  @override
  String get householdNameLabel => 'Nome do agregado';

  @override
  String get householdNameHint => 'ex: FamÃ­lia Silva';

  @override
  String get householdCodeLabel => 'CÃ³digo de convite';

  @override
  String get householdCodeHint => 'XXXXXX';

  @override
  String get householdCreateButton => 'Criar Agregado';

  @override
  String get householdJoinButton => 'Entrar no Agregado';

  @override
  String get householdNameRequired => 'Indica o nome do agregado.';

  @override
  String get chartExpensesByCategory => 'Despesas por Categoria';

  @override
  String get chartIncomeVsExpenses => 'Rendimento vs Despesas';

  @override
  String get chartDeductions => 'Descontos (IRS + SeguranÃ§a Social)';

  @override
  String get chartGrossVsNet => 'Rendimento Bruto vs LÃ­quido';

  @override
  String get chartSavingsRate => 'Taxa de PoupanÃ§a';

  @override
  String get chartNetIncome => 'Rend. Liq.';

  @override
  String get chartExpensesLabel => 'Despesas';

  @override
  String get chartLiquidity => 'Liquidez';

  @override
  String chartSalaryN(int n) {
    return 'Venc. $n';
  }

  @override
  String get chartGross => 'Bruto';

  @override
  String get chartNet => 'LÃ­quido';

  @override
  String get chartNetSalary => 'Sal. LÃ­quido';

  @override
  String get chartIRS => 'IRS';

  @override
  String get chartSocialSecurity => 'Seg. Social';

  @override
  String get chartSavings => 'poupanÃ§a';

  @override
  String projectionTitle(String month, String year) {
    return 'ProjeÃ§Ã£o â€” $month $year';
  }

  @override
  String projectionSubtitle(String spent, String budget, String days) {
    return 'Gastou $spent de $budget em $days dias';
  }

  @override
  String get projectionFood => 'ALIMENTAÃ‡ÃƒO';

  @override
  String get projectionCurrentPace => 'Ritmo atual';

  @override
  String get projectionNoShopping => 'Sem compras';

  @override
  String get projectionReduce20 => '-20%';

  @override
  String projectionDailySpend(String amount) {
    return 'Gasto diÃ¡rio estimado: $amount/dia';
  }

  @override
  String get projectionEndOfMonth => 'ProjeÃ§Ã£o fim de mÃªs';

  @override
  String get projectionRemaining => 'Restante projetado';

  @override
  String get projectionStressImpact => 'Impacto no Ãndice';

  @override
  String get projectionExpenses => 'DESPESAS';

  @override
  String get projectionSimulation => 'SimulaÃ§Ã£o â€” nÃ£o guardado';

  @override
  String get projectionReduceAll => 'Reduzir todas em ';

  @override
  String get projectionSimLiquidity => 'Liquidez simulada';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Taxa poupanÃ§a simulada';

  @override
  String get projectionSimIndex => 'Ãndice simulado';

  @override
  String get trendTitle => 'EvoluÃ§Ã£o';

  @override
  String get trendStressIndex => 'ÃNDICE DE TRANQUILIDADE';

  @override
  String get trendTotalExpenses => 'DESPESAS TOTAIS';

  @override
  String get trendExpensesByCategory => 'DESPESAS POR CATEGORIA';

  @override
  String trendCurrent(String amount) {
    return 'Atual: $amount';
  }

  @override
  String get trendCatTelecom => 'Telecom';

  @override
  String get trendCatEnergy => 'Energia';

  @override
  String get trendCatWater => 'Ãgua';

  @override
  String get trendCatFood => 'AlimentaÃ§Ã£o';

  @override
  String get trendCatEducation => 'EducaÃ§Ã£o';

  @override
  String get trendCatHousing => 'HabitaÃ§Ã£o';

  @override
  String get trendCatTransport => 'Transportes';

  @override
  String get trendCatHealth => 'SaÃºde';

  @override
  String get trendCatLeisure => 'Lazer';

  @override
  String get trendCatOther => 'Outros';

  @override
  String monthReviewTitle(String month) {
    return 'Resumo â€” $month';
  }

  @override
  String get monthReviewPlanned => 'Planeado';

  @override
  String get monthReviewActual => 'Real';

  @override
  String get monthReviewDifference => 'DiferenÃ§a';

  @override
  String get monthReviewFood => 'AlimentaÃ§Ã£o';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual de $budget';
  }

  @override
  String get monthReviewTopDeviations => 'MAIORES DESVIOS';

  @override
  String get monthReviewSuggestions => 'SUGESTÃ•ES';

  @override
  String get monthReviewAiAnalysis => 'AnÃ¡lise AI detalhada';

  @override
  String get mealPlannerTitle => 'Planeador de RefeiÃ§Ãµes';

  @override
  String get mealBudgetLabel => 'OrÃ§amento alimentaÃ§Ã£o';

  @override
  String get mealPeopleLabel => 'Pessoas no agregado';

  @override
  String get mealGeneratePlan => 'Gerar Plano Mensal';

  @override
  String get mealGenerating => 'A gerar...';

  @override
  String get mealRegenerateTitle => 'Regenerar plano?';

  @override
  String get mealRegenerateContent => 'O plano atual serÃ¡ substituÃ­do.';

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
  String get mealAddWeekToList => 'Adicionar semana Ã  lista';

  @override
  String mealIngredientsAdded(int count) {
    return '$count ingredientes adicionados Ã  lista';
  }

  @override
  String mealDayLabel(int n) {
    return 'Dia $n';
  }

  @override
  String get mealIngredients => 'Ingredientes';

  @override
  String get mealPreparation => 'PreparaÃ§Ã£o';

  @override
  String get mealSwap => 'Trocar';

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
  String get mealCatVegetables => 'Vegetais';

  @override
  String get mealCatCarbs => 'Hidratos';

  @override
  String get mealCatFats => 'Gorduras';

  @override
  String get mealCatCondiments => 'Condimentos';

  @override
  String mealCostPerPerson(String cost) {
    return '$costâ‚¬/pess';
  }

  @override
  String get mealNutriProt => 'prot';

  @override
  String get mealNutriCarbs => 'carbs';

  @override
  String get mealNutriFat => 'gord';

  @override
  String get mealNutriFiber => 'fibra';

  @override
  String get wizardStepMeals => 'RefeiÃ§Ãµes';

  @override
  String get wizardStepObjective => 'Objetivo';

  @override
  String get wizardStepRestrictions => 'RestriÃ§Ãµes';

  @override
  String get wizardStepKitchen => 'Cozinha';

  @override
  String get wizardStepStrategy => 'EstratÃ©gia';

  @override
  String get wizardMealsQuestion =>
      'Quais refeiÃ§Ãµes queres incluir no plano diÃ¡rio?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight do orÃ§amento';
  }

  @override
  String get wizardObjectiveQuestion =>
      'Qual Ã© o objetivo principal do teu plano alimentar?';

  @override
  String wizardSelected(String label) {
    return '$label, selecionado';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRIÃ‡Ã•ES DIETÃ‰TICAS';

  @override
  String get wizardGlutenFree => 'Sem glÃºten';

  @override
  String get wizardLactoseFree => 'Sem lactose';

  @override
  String get wizardNutFree => 'Sem frutos secos';

  @override
  String get wizardShellfishFree => 'Sem marisco';

  @override
  String get wizardDislikedIngredients => 'INGREDIENTES QUE NÃƒO GOSTAS';

  @override
  String get wizardDislikedHint => 'ex: atum, brÃ³colos';

  @override
  String get wizardMaxPrepTime => 'TEMPO MÃXIMO POR REFEIÃ‡ÃƒO';

  @override
  String get wizardMaxComplexity => 'COMPLEXIDADE MÃXIMA';

  @override
  String get wizardComplexityEasy => 'FÃ¡cil';

  @override
  String get wizardComplexityMedium => 'MÃ©dio';

  @override
  String get wizardComplexityAdvanced => 'AvanÃ§ado';

  @override
  String get wizardEquipment => 'EQUIPAMENTO DISPONÃVEL';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc => 'Cozinhar para vÃ¡rios dias de uma vez';

  @override
  String get wizardMaxBatchDays => 'MÃXIMO DE DIAS POR RECEITA';

  @override
  String wizardBatchDays(int days) {
    return '$days dias';
  }

  @override
  String get wizardPreferredCookingDay => 'DIA PREFERIDO PARA COZINHAR';

  @override
  String get wizardReuseLeftovers => 'Reaproveitar sobras';

  @override
  String get wizardReuseLeftoversDesc =>
      'Jantar de ontem = almoÃ§o de hoje (custo 0)';

  @override
  String get wizardMaxNewIngredients =>
      'MÃXIMO DE INGREDIENTES NOVOS POR SEMANA';

  @override
  String get wizardNoLimit => 'Sem limite';

  @override
  String get wizardMinimizeWaste => 'Minimizar desperdÃ­cio';

  @override
  String get wizardMinimizeWasteDesc =>
      'Prefere receitas que reutilizam ingredientes jÃ¡ usados';

  @override
  String get wizardSettingsInfo =>
      'Podes alterar as definiÃ§Ãµes do planeador em qualquer altura em DefiniÃ§Ãµes â†’ RefeiÃ§Ãµes.';

  @override
  String get wizardContinue => 'Continuar';

  @override
  String get wizardGeneratePlan => 'Gerar Plano';

  @override
  String wizardStepOf(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get wizardWeekdayMon => 'Seg';

  @override
  String get wizardWeekdayTue => 'Ter';

  @override
  String get wizardWeekdayWed => 'Qua';

  @override
  String get wizardWeekdayThu => 'Qui';

  @override
  String get wizardWeekdayFri => 'Sex';

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
  String get settingsTitle => 'DefiniÃ§Ãµes';

  @override
  String get settingsPersonal => 'Dados Pessoais';

  @override
  String get settingsSalaries => 'SalÃ¡rios';

  @override
  String get settingsExpenses => 'OrÃ§amento e Pagamentos Recorrentes';

  @override
  String get settingsCoachAi => 'Coach IA';

  @override
  String get settingsDashboard => 'Dashboard';

  @override
  String get settingsMeals => 'RefeiÃ§Ãµes';

  @override
  String get settingsRegion => 'RegiÃ£o e Idioma';

  @override
  String get settingsCountry => 'PaÃ­s';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsMaritalStatus => 'Estado civil';

  @override
  String get settingsDependents => 'Dependentes';

  @override
  String get settingsDisability => 'Deficiente';

  @override
  String get settingsGrossSalary => 'SalÃ¡rio bruto';

  @override
  String get settingsTitulares => 'Titulares';

  @override
  String get settingsSubsidyMode => 'DuodÃ©cimos';

  @override
  String get settingsMealAllowance => 'SubsÃ­dio de alimentaÃ§Ã£o';

  @override
  String get settingsMealAllowancePerDay => 'Valor/dia';

  @override
  String get settingsWorkingDays => 'Dias Ãºteis/mÃªs';

  @override
  String get settingsOtherExemptIncome => 'Outros rendimentos isentos';

  @override
  String get settingsAddSalary => 'Adicionar salÃ¡rio';

  @override
  String get settingsAddExpense => 'Adicionar categoria';

  @override
  String get settingsExpenseName => 'Nome da categoria';

  @override
  String get settingsExpenseAmount => 'Valor';

  @override
  String get settingsExpenseCategory => 'Categoria';

  @override
  String get settingsApiKey => 'API Key OpenAI';

  @override
  String get settingsInviteCode => 'CÃ³digo de convite';

  @override
  String get settingsCopyCode => 'Copiar';

  @override
  String get settingsCodeCopied => 'CÃ³digo copiado!';

  @override
  String get settingsAdminOnly =>
      'Apenas o administrador pode editar as definiÃ§Ãµes.';

  @override
  String get settingsShowSummaryCards => 'Mostrar cartÃµes resumo';

  @override
  String get settingsEnabledCharts => 'GrÃ¡ficos ativos';

  @override
  String get settingsLogout => 'Terminar sessÃ£o';

  @override
  String get settingsLogoutConfirmTitle => 'Terminar sessÃ£o';

  @override
  String get settingsLogoutConfirmContent => 'Tens a certeza que queres sair?';

  @override
  String get settingsLogoutConfirmButton => 'Sair';

  @override
  String get settingsSalariesSection => 'Vencimentos';

  @override
  String get settingsExpensesMonthly => 'OrÃ§amento e Pagamentos Recorrentes';

  @override
  String get settingsFavorites => 'Produtos Favoritos';

  @override
  String get settingsCoachOpenAi => 'Coach IA (OpenAI)';

  @override
  String get settingsHousehold => 'Agregado';

  @override
  String get settingsMaritalStatusLabel => 'ESTADO CIVIL';

  @override
  String get settingsDependentsLabel => 'NÃšMERO DE DEPENDENTES';

  @override
  String settingsSocialSecurityRate(String rate) {
    return 'SeguranÃ§a Social: $rate';
  }

  @override
  String get settingsSalaryActive => 'Ativo';

  @override
  String get settingsGrossMonthlySalary => 'SALÃRIO BRUTO MENSAL';

  @override
  String get settingsSubsidyHoliday =>
      'SUBSÃDIOS DE FÃ‰RIAS E NATAL (DUODÃ‰CIMOS)';

  @override
  String get settingsOtherExemptLabel => 'OUTROS RENDIMENTOS ISENTOS DE IRS';

  @override
  String get settingsMealAllowanceLabel => 'SUBSÃDIO DE ALIMENTAÃ‡ÃƒO';

  @override
  String get settingsAmountPerDay => 'VALOR/DIA';

  @override
  String get settingsDaysPerMonth => 'DIAS/MÃŠS';

  @override
  String get settingsTitularesLabel => 'N. TITULARES';

  @override
  String settingsTitularCount(int n, String suffix) {
    return '$n Titular$suffix';
  }

  @override
  String get settingsAddSalaryButton => 'Adicionar vencimento';

  @override
  String get settingsAddExpenseButton => 'Adicionar Categoria';

  @override
  String get settingsDeviceLocal =>
      'Estas definiÃ§Ãµes sÃ£o guardadas neste dispositivo.';

  @override
  String get settingsVisibleSections => 'SECÃ‡Ã•ES VISÃVEIS';

  @override
  String get settingsMinimalist => 'Minimalista';

  @override
  String get settingsFull => 'Completo';

  @override
  String get settingsDashMonthlyLiquidity => 'Liquidez mensal';

  @override
  String get settingsDashStressIndex => 'Ãndice de Tranquilidade';

  @override
  String get settingsDashSummaryCards => 'CartÃµes de resumo';

  @override
  String get settingsDashSalaryBreakdown => 'Detalhe por vencimento';

  @override
  String get settingsDashFood => 'AlimentaÃ§Ã£o';

  @override
  String get settingsDashPurchaseHistory => 'HistÃ³rico de compras';

  @override
  String get settingsDashExpensesBreakdown => 'Breakdown despesas';

  @override
  String get settingsDashMonthReview => 'RevisÃ£o do mÃªs';

  @override
  String get settingsDashCharts => 'GrÃ¡ficos';

  @override
  String get dashGroupOverview => 'VISÃƒO GERAL';

  @override
  String get dashGroupFinancialDetail => 'DETALHE FINANCEIRO';

  @override
  String get dashGroupHistory => 'HISTÃ“RICO';

  @override
  String get dashGroupCharts => 'GRÃFICOS';

  @override
  String get settingsVisibleCharts => 'GRÃFICOS VISÃVEIS';

  @override
  String get settingsFavTip =>
      'Os produtos favoritos influenciam o plano de refeiÃ§Ãµes â€” receitas com esses ingredientes ficam em prioridade.';

  @override
  String get settingsMyFavorites => 'OS MEUS FAVORITOS';

  @override
  String get settingsProductCatalog => 'CATÃLOGO DE PRODUTOS';

  @override
  String get settingsSearchProduct => 'Pesquisar produto...';

  @override
  String get settingsLoadingProducts => 'A carregar produtos...';

  @override
  String get settingsAddIngredient => 'Adicionar ingrediente';

  @override
  String get settingsIngredientName => 'Nome do ingrediente';

  @override
  String get settingsAddButton => 'Adicionar';

  @override
  String get settingsAddToPantry => 'Adicionar Ã  despensa';

  @override
  String get settingsHouseholdPeople => 'AGREGADO (PESSOAS)';

  @override
  String get settingsAutomatic => '(auto)';

  @override
  String get settingsUseAutoValue => 'Usar valor automÃ¡tico';

  @override
  String settingsManualValue(int count) {
    return 'Valor manual: $count pessoas';
  }

  @override
  String settingsAutoValue(int count) {
    return 'Calculado automaticamente: $count (titulares + dependentes)';
  }

  @override
  String get settingsHouseholdMembers => 'MEMBROS DO AGREGADO';

  @override
  String get settingsPortions => 'porÃ§Ãµes';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Equivalente total: $total porÃ§Ãµes';
  }

  @override
  String get settingsAddMember => 'Adicionar membro';

  @override
  String get settingsPreferSeasonal => 'Preferir receitas sazonais';

  @override
  String get settingsPreferSeasonalDesc => 'Prioriza receitas da Ã©poca atual';

  @override
  String get settingsNutritionalGoals => 'OBJETIVOS NUTRICIONAIS';

  @override
  String get settingsCalorieHint => 'ex: 2000';

  @override
  String get settingsKcalPerDay => 'kcal/dia';

  @override
  String get settingsProteinHint => 'ex: 60';

  @override
  String get settingsGramsPerDay => 'g/dia';

  @override
  String get settingsFiberHint => 'ex: 25';

  @override
  String get settingsDailyProtein => 'ProteÃ­na diÃ¡ria';

  @override
  String get settingsDailyFiber => 'Fibra diÃ¡ria';

  @override
  String get settingsMedicalConditions => 'CONDIÃ‡Ã•ES MÃ‰DICAS';

  @override
  String get settingsActiveMeals => 'REFEIÃ‡Ã•ES ATIVAS';

  @override
  String get settingsObjective => 'OBJETIVO';

  @override
  String get settingsVeggieDays => 'DIAS VEGETARIANOS POR SEMANA';

  @override
  String get settingsDietaryRestrictions => 'RESTRIÃ‡Ã•ES DIETÃ‰TICAS';

  @override
  String get settingsEggFree => 'Sem ovos';

  @override
  String get settingsSodiumPref => 'PREFERÃŠNCIA DE SÃ“DIO';

  @override
  String get settingsDislikedIngredients => 'INGREDIENTES INDESEJADOS';

  @override
  String get settingsExcludedProteins => 'PROTEÃNAS EXCLUÃDAS';

  @override
  String get settingsProteinChicken => 'Frango';

  @override
  String get settingsProteinGroundMeat => 'Carne Picada';

  @override
  String get settingsProteinPork => 'Porco';

  @override
  String get settingsProteinHake => 'Pescada';

  @override
  String get settingsProteinCod => 'Bacalhau';

  @override
  String get settingsProteinSardine => 'Sardinha';

  @override
  String get settingsProteinTuna => 'Atum';

  @override
  String get settingsProteinEgg => 'Ovos';

  @override
  String get settingsMaxPrepTime => 'TEMPO MÃXIMO (MINUTOS)';

  @override
  String settingsMaxComplexity(int value) {
    return 'COMPLEXIDADE MÃXIMA ($value/5)';
  }

  @override
  String get settingsWeekendPrepTime => 'TEMPO FIM-DE-SEMANA (MINUTOS)';

  @override
  String settingsWeekendComplexity(int value) {
    return 'COMPLEXIDADE FIM-DE-SEMANA ($value/5)';
  }

  @override
  String get settingsEatingOutDays => 'DIAS DE COMER FORA';

  @override
  String get settingsWeeklyDistribution => 'DISTRIBUIÃ‡ÃƒO SEMANAL';

  @override
  String settingsFishPerWeek(String count) {
    return 'Peixe por semana: $count';
  }

  @override
  String get settingsNoMinimum => 'sem mÃ­nimo';

  @override
  String settingsLegumePerWeek(String count) {
    return 'Leguminosas por semana: $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Carne vermelha mÃ¡x/semana: $count';
  }

  @override
  String get settingsNoLimit => 'sem limite';

  @override
  String get settingsAvailableEquipment => 'EQUIPAMENTO DISPONÃVEL';

  @override
  String get settingsBatchCooking => 'Batch cooking';

  @override
  String get settingsMaxBatchDays => 'MÃXIMO DE DIAS POR RECEITA';

  @override
  String get settingsReuseLeftovers => 'Reaproveitar sobras';

  @override
  String get settingsMinimizeWaste => 'Minimizar desperdÃ­cio';

  @override
  String get settingsPrioritizeLowCost => 'Priorizar custo baixo';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'Preferir receitas mais econÃ³micas';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'INGREDIENTES NOVOS POR SEMANA ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'AlmoÃ§os de marmita';

  @override
  String get settingsLunchboxLunchesDesc =>
      'Apenas receitas transportÃ¡veis ao almoÃ§o';

  @override
  String get settingsPantry => 'DESPENSA (SEMPRE EM STOCK)';

  @override
  String get settingsResetWizard => 'Repor Wizard';

  @override
  String get settingsApiKeyInfo =>
      'A key Ã© guardada localmente no dispositivo e nunca Ã© partilhada. Usa o modelo GPT-4o mini (~â‚¬0,00008 por anÃ¡lise).';

  @override
  String get settingsInviteCodeLabel => 'CÃ“DIGO DE CONVITE';

  @override
  String get settingsGenerateInvite => 'Gerar cÃ³digo de convite';

  @override
  String get settingsShareWithMembers => 'Partilha com membros do agregado';

  @override
  String get settingsNewCode => 'Novo cÃ³digo';

  @override
  String get settingsCodeValidInfo =>
      'O cÃ³digo Ã© vÃ¡lido por 7 dias. Partilha-o com quem queres adicionar ao agregado.';

  @override
  String get settingsName => 'Nome';

  @override
  String get settingsAgeGroup => 'Faixa etÃ¡ria';

  @override
  String get settingsActivityLevel => 'NÃ­vel de atividade';

  @override
  String settingsSalaryN(int n) {
    return 'Vencimento $n';
  }

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryES => 'Espanha';

  @override
  String get countryFR => 'FranÃ§a';

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
  String get taxIncomeTax => 'Imposto sobre rendimento';

  @override
  String get taxSocialContribution => 'ContribuiÃ§Ã£o social';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'SeguranÃ§a Social';

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
      'Ã‰s um analista financeiro pessoal para utilizadores portugueses. Responde sempre em portuguÃªs europeu. SÃª directo e analÃ­tico â€” usa sempre nÃºmeros concretos do contexto fornecido. Estrutura a resposta exactamente nas 3 partes pedidas. NÃ£o introduzas dados, benchmarks ou referÃªncias externas que nÃ£o foram fornecidos.';

  @override
  String get aiCoachInvalidApiKey =>
      'API key invÃ¡lida. Verifica nas DefiniÃ§Ãµes.';

  @override
  String get aiCoachMidMonthSystem =>
      'Ã‰s um consultor de orÃ§amento domÃ©stico portuguÃªs. Responde sempre em portuguÃªs europeu. SÃª prÃ¡tico e directo.';

  @override
  String get aiMealPlannerSystem =>
      'Ã‰s um chef portuguÃªs. Responde sempre em portuguÃªs europeu. Responde APENAS com JSON vÃ¡lido, sem texto extra.';

  @override
  String get monthAbbrJan => 'Jan';

  @override
  String get monthAbbrFeb => 'Fev';

  @override
  String get monthAbbrMar => 'Mar';

  @override
  String get monthAbbrApr => 'Abr';

  @override
  String get monthAbbrMay => 'Mai';

  @override
  String get monthAbbrJun => 'Jun';

  @override
  String get monthAbbrJul => 'Jul';

  @override
  String get monthAbbrAug => 'Ago';

  @override
  String get monthAbbrSep => 'Set';

  @override
  String get monthAbbrOct => 'Out';

  @override
  String get monthAbbrNov => 'Nov';

  @override
  String get monthAbbrDec => 'Dez';

  @override
  String get monthFullJan => 'Janeiro';

  @override
  String get monthFullFeb => 'Fevereiro';

  @override
  String get monthFullMar => 'MarÃ§o';

  @override
  String get monthFullApr => 'Abril';

  @override
  String get monthFullMay => 'Maio';

  @override
  String get monthFullJun => 'Junho';

  @override
  String get monthFullJul => 'Julho';

  @override
  String get monthFullAug => 'Agosto';

  @override
  String get monthFullSep => 'Setembro';

  @override
  String get monthFullOct => 'Outubro';

  @override
  String get monthFullNov => 'Novembro';

  @override
  String get monthFullDec => 'Dezembro';

  @override
  String get setupWizardWelcomeTitle => 'Bem-vindo ao seu orÃ§amento';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Vamos configurar o essencial para que o seu painel fique pronto a usar.';

  @override
  String get setupWizardBullet1 => 'Calcular o seu salÃ¡rio lÃ­quido';

  @override
  String get setupWizardBullet2 => 'Organizar as suas despesas';

  @override
  String get setupWizardBullet3 => 'Ver quanto sobra cada mÃªs';

  @override
  String get setupWizardReassurance =>
      'Pode alterar tudo mais tarde nas definiÃ§Ãµes.';

  @override
  String get setupWizardStart => 'ComeÃ§ar';

  @override
  String get setupWizardSkipAll => 'Saltar configuraÃ§Ã£o';

  @override
  String setupWizardStepOf(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get setupWizardContinue => 'Continuar';

  @override
  String get setupWizardCountryTitle => 'Onde vive?';

  @override
  String get setupWizardCountrySubtitle =>
      'Isto define o sistema fiscal, moeda e valores por defeito.';

  @override
  String get setupWizardLanguage => 'Idioma';

  @override
  String get setupWizardLangSystem => 'PredefiniÃ§Ã£o do sistema';

  @override
  String get setupWizardCountryPT => 'Portugal';

  @override
  String get setupWizardCountryES => 'Espanha';

  @override
  String get setupWizardCountryFR => 'FranÃ§a';

  @override
  String get setupWizardCountryUK => 'Reino Unido';

  @override
  String get setupWizardPersonalTitle => 'InformaÃ§Ã£o pessoal';

  @override
  String get setupWizardPersonalSubtitle =>
      'Usamos isto para calcular os seus impostos com mais precisÃ£o.';

  @override
  String get setupWizardPrivacyNote =>
      'Os seus dados ficam na sua conta e nunca sÃ£o partilhados.';

  @override
  String get setupWizardSingle => 'Solteiro(a)';

  @override
  String get setupWizardMarried => 'Casado(a)';

  @override
  String get setupWizardDependents => 'Dependentes';

  @override
  String get setupWizardTitulares => 'Titulares';

  @override
  String get setupWizardSalaryTitle => 'Qual Ã© o seu salÃ¡rio?';

  @override
  String get setupWizardSalarySubtitle =>
      'Introduza o valor bruto mensal. Calculamos o lÃ­quido automaticamente.';

  @override
  String get setupWizardSalaryGross => 'SalÃ¡rio bruto mensal';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'LÃ­quido estimado: $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Pode adicionar mais fontes de rendimento mais tarde.';

  @override
  String get setupWizardSalaryRequired => 'Por favor insira o seu salÃ¡rio';

  @override
  String get setupWizardSalaryPositive =>
      'O salÃ¡rio deve ser um nÃºmero positivo';

  @override
  String get setupWizardSalarySkip => 'Saltar este passo';

  @override
  String get setupWizardExpensesTitle => 'As suas despesas mensais';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valores sugeridos para o seu paÃ­s. Ajuste conforme necessÃ¡rio.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Pode adicionar mais categorias mais tarde.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'LÃ­quido: $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'Despesas: $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'DisponÃ­vel: $amount';
  }

  @override
  String get setupWizardFinish => 'Concluir';

  @override
  String get setupWizardCompleteTitle => 'Tudo pronto!';

  @override
  String get setupWizardCompleteReassurance =>
      'O seu orÃ§amento estÃ¡ configurado. Pode ajustar tudo nas definiÃ§Ãµes a qualquer momento.';

  @override
  String get setupWizardGoToDashboard => 'Ver o meu orÃ§amento';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configure o seu salÃ¡rio nas definiÃ§Ãµes para ver o cÃ¡lculo completo.';

  @override
  String get setupWizardExpRent => 'Renda / PrestaÃ§Ã£o';

  @override
  String get setupWizardExpGroceries => 'AlimentaÃ§Ã£o';

  @override
  String get setupWizardExpTransport => 'Transportes';

  @override
  String get setupWizardExpUtilities => 'Utilidades (luz, Ã¡gua, gÃ¡s)';

  @override
  String get setupWizardExpTelecom => 'TelecomunicaÃ§Ãµes';

  @override
  String get setupWizardExpHealth => 'SaÃºde';

  @override
  String get setupWizardExpLeisure => 'Lazer';

  @override
  String get expenseTrackerTitle => 'ORÃ‡AMENTO VS REAL';

  @override
  String get expenseTrackerBudgeted => 'OrÃ§amentado';

  @override
  String get expenseTrackerActual => 'Real';

  @override
  String get expenseTrackerRemaining => 'Restante';

  @override
  String get expenseTrackerOver => 'Acima do orÃ§amento';

  @override
  String get expenseTrackerViewAll => 'Ver detalhes';

  @override
  String get expenseTrackerNoExpenses => 'Ainda sem despesas registadas.';

  @override
  String get expenseTrackerScreenTitle => 'Controlo de Despesas';

  @override
  String expenseTrackerMonthTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String get expenseTrackerDeleteConfirm => 'Eliminar esta despesa?';

  @override
  String get expenseTrackerEmpty =>
      'Sem despesas este mÃªs.\nToca + para adicionar a primeira.';

  @override
  String get addExpenseTitle => 'Adicionar Despesa';

  @override
  String get editExpenseTitle => 'Editar Despesa';

  @override
  String get addExpenseCategory => 'Categoria';

  @override
  String get addExpenseAmount => 'Montante';

  @override
  String get addExpenseDate => 'Data';

  @override
  String get addExpenseDescription => 'DescriÃ§Ã£o (opcional)';

  @override
  String get addExpenseCustomCategory => 'Categoria personalizada';

  @override
  String get addExpenseInvalidAmount => 'Introduza um valor vÃ¡lido';

  @override
  String get addExpenseTooltip => 'Registar despesa';

  @override
  String get addExpenseItem => 'Despesa';

  @override
  String get addExpenseOthers => 'Outros';

  @override
  String get settingsDashBudgetVsActual => 'OrÃ§amento vs Real';

  @override
  String get settingsAppearance => 'AparÃªncia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get recurringExpenses => 'Pagamentos Recorrentes';

  @override
  String get recurringExpenseAdd => 'Adicionar Pagamento Recorrente';

  @override
  String get recurringExpenseEdit => 'Editar Pagamento Recorrente';

  @override
  String get recurringExpenseCategory => 'Categoria';

  @override
  String get recurringExpenseAmount => 'Montante';

  @override
  String get recurringExpenseDescription => 'DescriÃ§Ã£o (opcional)';

  @override
  String get recurringExpenseDayOfMonth => 'Dia de vencimento';

  @override
  String get recurringExpenseActive => 'Ativa';

  @override
  String get recurringExpenseInactive => 'Inativa';

  @override
  String get recurringExpenseEmpty =>
      'Sem pagamentos recorrentes.\nAdicione para gerar automaticamente todos os meses.';

  @override
  String get recurringExpenseDeleteConfirm =>
      'Eliminar este pagamento recorrente?';

  @override
  String get recurringExpenseAutoCreated => 'Criada automaticamente';

  @override
  String get recurringExpenseManage => 'Gerir pagamentos recorrentes';

  @override
  String get recurringExpenseMarkRecurring =>
      'Marcar como pagamento recorrente';

  @override
  String get recurringExpensePopulated =>
      'Pagamentos recorrentes gerados para este mÃªs';

  @override
  String get recurringExpenseDayHint => 'Ex: 1 para dia 1';

  @override
  String get recurringExpenseNoDay => 'Sem dia fixo';

  @override
  String get recurringExpenseSaved => 'Pagamento recorrente guardado';

  @override
  String get recurringPaymentToggle => 'Pagamento recorrente';

  @override
  String billsCount(int count) {
    return '$count pagamentos';
  }

  @override
  String get billsNone => 'Sem pagamentos recorrentes';

  @override
  String billsPerMonth(int count, String amount) {
    return '$count pagamentos Â· $amount/mÃªs';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Contas ($amount) excedem orÃ§amento';
  }

  @override
  String get billsAddBill => 'Adicionar Pagamento Recorrente';

  @override
  String get billsBudgetSettings => 'ConfiguraÃ§Ã£o do OrÃ§amento';

  @override
  String get billsRecurringBills => 'Pagamentos Recorrentes';

  @override
  String get billsDescription => 'DescriÃ§Ã£o';

  @override
  String get billsAmount => 'Montante';

  @override
  String get billsDueDay => 'Dia de vencimento';

  @override
  String get billsActive => 'Ativa';

  @override
  String get expenseTrends => 'TendÃªncias de Despesas';

  @override
  String get expenseTrendsViewTrends => 'Ver TendÃªncias';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'OrÃ§amentado';

  @override
  String get expenseTrendsActual => 'Real';

  @override
  String get expenseTrendsByCategory => 'Por Categoria';

  @override
  String get expenseTrendsNoData =>
      'Sem dados suficientes para mostrar tendÃªncias.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'MÃ©dia';

  @override
  String get expenseTrendsOverview => 'VisÃ£o Geral';

  @override
  String get expenseTrendsMonthly => 'Mensal';

  @override
  String get savingsGoals => 'Objetivos de PoupanÃ§a';

  @override
  String get savingsGoalAdd => 'Novo Objetivo';

  @override
  String get savingsGoalEdit => 'Editar Objetivo';

  @override
  String get savingsGoalName => 'Nome do objetivo';

  @override
  String get savingsGoalTarget => 'Valor alvo';

  @override
  String get savingsGoalCurrent => 'Valor atual';

  @override
  String get savingsGoalDeadline => 'Data limite';

  @override
  String get savingsGoalNoDeadline => 'Sem data limite';

  @override
  String get savingsGoalColor => 'Cor';

  @override
  String savingsGoalProgress(String percent) {
    return '$percent% alcanÃ§ado';
  }

  @override
  String savingsGoalRemaining(String amount) {
    return 'Faltam $amount';
  }

  @override
  String get savingsGoalCompleted => 'Objetivo alcanÃ§ado!';

  @override
  String get savingsGoalEmpty =>
      'Sem objetivos de poupanÃ§a.\nCrie um para acompanhar o progresso.';

  @override
  String get savingsGoalDeleteConfirm => 'Eliminar este objetivo?';

  @override
  String get savingsGoalContribute => 'Contribuir';

  @override
  String get savingsGoalContributionAmount => 'Valor da contribuiÃ§Ã£o';

  @override
  String get savingsGoalContributionNote => 'Nota (opcional)';

  @override
  String get savingsGoalContributionDate => 'Data';

  @override
  String get savingsGoalContributionHistory => 'HistÃ³rico de ContribuiÃ§Ãµes';

  @override
  String get savingsGoalSeeAll => 'Ver todos';

  @override
  String savingsGoalSurplusSuggestion(String amount) {
    return 'Tiveste $amount de excedente no mÃªs passado â€” queres alocar a um objetivo?';
  }

  @override
  String get savingsGoalAllocate => 'Alocar';

  @override
  String get savingsGoalSaved => 'Objetivo guardado';

  @override
  String get savingsGoalContributionSaved => 'ContribuiÃ§Ã£o registada';

  @override
  String get settingsDashSavingsGoals => 'Objetivos de PoupanÃ§a';

  @override
  String get savingsGoalActive => 'Ativo';

  @override
  String get savingsGoalInactive => 'Inativo';

  @override
  String savingsGoalDaysLeft(String days) {
    return '$days dias restantes';
  }

  @override
  String get savingsGoalOverdue => 'Prazo ultrapassado';

  @override
  String get mealCostReconciliation => 'Custos de RefeiÃ§Ãµes';

  @override
  String get mealCostEstimated => 'Estimado';

  @override
  String get mealCostActual => 'Real';

  @override
  String mealCostWeek(String number) {
    return 'Semana $number';
  }

  @override
  String get mealCostTotal => 'Total do MÃªs';

  @override
  String get mealCostSavings => 'PoupanÃ§a';

  @override
  String get mealCostOverrun => 'Excesso';

  @override
  String get mealCostNoData => 'Sem dados de compras para refeiÃ§Ãµes.';

  @override
  String get mealCostViewCosts => 'Custos';

  @override
  String get mealCostIsMealPurchase => 'Compra para refeiÃ§Ãµes';

  @override
  String get mealCostVsBudget => 'vs orÃ§amento';

  @override
  String get mealCostOnTrack => 'Dentro do orÃ§amento';

  @override
  String get mealCostOver => 'Acima do orÃ§amento';

  @override
  String get mealCostUnder => 'Abaixo do orÃ§amento';

  @override
  String get mealVariation => 'VariaÃ§Ã£o';

  @override
  String get mealPairing => 'Acompanhamento';

  @override
  String get mealStorage => 'ConservaÃ§Ã£o';

  @override
  String get mealLeftover => 'Sobras';

  @override
  String get mealLeftoverIdea => 'Ideia de reaproveitamento';

  @override
  String get mealWeeklySummary => 'NutriÃ§Ã£o Semanal';

  @override
  String get mealBatchPrepGuide => 'Cozinha em Lote';

  @override
  String get mealViewPrepGuide => 'PreparaÃ§Ã£o';

  @override
  String get mealPrepGuideTitle => 'Como Preparar';

  @override
  String mealPrepTime(String minutes) {
    return 'Tempo: $minutes min';
  }

  @override
  String mealBatchTotalTime(String time) {
    return 'Tempo estimado: $time';
  }

  @override
  String get mealBatchParallelTips => 'Dicas de cozinha paralela';

  @override
  String get mealFeedbackLike => 'Gostei';

  @override
  String get mealFeedbackDislike => 'NÃ£o gostei';

  @override
  String get mealFeedbackSkip => 'Saltar';

  @override
  String get mealRateRecipe => 'Avaliar receita';

  @override
  String mealRatingLabel(int rating) {
    return '$rating estrelas';
  }

  @override
  String get mealRatingUnrated => 'Sem avaliacao';

  @override
  String get notifications => 'NotificaÃ§Ãµes';

  @override
  String get notificationSettings => 'DefiniÃ§Ãµes de NotificaÃ§Ãµes';

  @override
  String get notificationPreferredTime => 'Hora preferida';

  @override
  String get notificationPreferredTimeDesc =>
      'NotificaÃ§Ãµes agendadas usarÃ£o esta hora (exceto lembretes personalizados)';

  @override
  String get notificationBillReminders => 'Lembretes de pagamentos';

  @override
  String get notificationBillReminderDays => 'Dias antes do vencimento';

  @override
  String get notificationBudgetAlerts => 'Alertas de orÃ§amento';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'Limite de alerta ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Lembrete de plano de refeiÃ§Ãµes';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifica se nÃ£o hÃ¡ plano para o mÃªs atual';

  @override
  String get notificationCustomReminders => 'Lembretes Personalizados';

  @override
  String get notificationAddCustom => 'Adicionar Lembrete';

  @override
  String get notificationCustomTitle => 'TÃ­tulo';

  @override
  String get notificationCustomBody => 'Mensagem';

  @override
  String get notificationCustomTime => 'Hora';

  @override
  String get notificationCustomRepeat => 'Repetir';

  @override
  String get notificationCustomRepeatDaily => 'DiÃ¡rio';

  @override
  String get notificationCustomRepeatWeekly => 'Semanal';

  @override
  String get notificationCustomRepeatMonthly => 'Mensal';

  @override
  String get notificationCustomRepeatNone => 'NÃ£o repetir';

  @override
  String get notificationCustomSaved => 'Lembrete guardado';

  @override
  String get notificationCustomDeleteConfirm => 'Eliminar este lembrete?';

  @override
  String get notificationEmpty => 'Sem lembretes personalizados.';

  @override
  String notificationBillTitle(String name) {
    return 'Pagamento a vencer: $name';
  }

  @override
  String notificationBillBody(String amount, String days) {
    return '$amount vence em $days dias';
  }

  @override
  String get notificationBudgetTitle => 'Alerta de orÃ§amento';

  @override
  String notificationBudgetBody(String percent) {
    return 'JÃ¡ gastaste $percent% do orÃ§amento mensal';
  }

  @override
  String get notificationMealPlanTitle => 'Plano de refeiÃ§Ãµes';

  @override
  String get notificationMealPlanBody =>
      'Ainda nÃ£o geraste o plano de refeiÃ§Ãµes deste mÃªs';

  @override
  String get notificationPermissionRequired =>
      'PermissÃ£o de notificaÃ§Ãµes necessÃ¡ria';

  @override
  String get notificationSelectDays => 'Selecionar dias';

  @override
  String get settingsColorPalette => 'Paleta de cores';

  @override
  String get paletteOcean => 'Oceano';

  @override
  String get paletteEmerald => 'Esmeralda';

  @override
  String get paletteViolet => 'Violeta';

  @override
  String get paletteTeal => 'Azul-petrÃ³leo';

  @override
  String get paletteSunset => 'PÃ´r do sol';

  @override
  String get exportTooltip => 'Exportar';

  @override
  String get exportTitle => 'Exportar mÃªs';

  @override
  String get exportPdf => 'RelatÃ³rio PDF';

  @override
  String get exportPdfDesc => 'RelatÃ³rio formatado com orÃ§amento vs real';

  @override
  String get exportCsv => 'Dados CSV';

  @override
  String get exportCsvDesc => 'Dados brutos para folha de cÃ¡lculo';

  @override
  String get exportReportTitle => 'RelatÃ³rio Mensal de Despesas';

  @override
  String get exportBudgetVsActual => 'OrÃ§amento vs Real';

  @override
  String get exportExpenseDetail => 'Detalhe de Despesas';

  @override
  String get searchExpenses => 'Pesquisar';

  @override
  String get searchExpensesHint => 'Pesquisar por descriÃ§Ã£o...';

  @override
  String get searchDateRange => 'PerÃ­odo';

  @override
  String get searchNoResults => 'Nenhuma despesa encontrada';

  @override
  String searchResultCount(int count) {
    return '$count resultados';
  }

  @override
  String get expenseFixed => 'Fixo';

  @override
  String get expenseVariable => 'VariÃ¡vel';

  @override
  String monthlyBudgetHint(String month) {
    return 'OrÃ§amento para $month';
  }

  @override
  String unsetBudgetsWarning(int count) {
    return '$count orÃ§amentos variÃ¡veis por definir';
  }

  @override
  String get unsetBudgetsCta => 'Definir nas definiÃ§Ãµes';

  @override
  String paceProjected(String amount) {
    return 'ProjeÃ§Ã£o: $amount';
  }

  @override
  String get onbSkip => 'Saltar';

  @override
  String get onbNext => 'Seguinte';

  @override
  String get onbGetStarted => 'ComeÃ§ar';

  @override
  String get onbSlide0Title => 'O seu orÃ§amento, num relance';

  @override
  String get onbSlide0Body =>
      'O painel mostra a sua liquidez mensal, despesas e Ãndice de Serenidade.';

  @override
  String get onbSlide1Title => 'Registe cada despesa';

  @override
  String get onbSlide1Body =>
      'Toque + para registar uma compra. Atribua uma categoria e veja as barras atualizarem.';

  @override
  String get onbSlide2Title => 'Compre com lista';

  @override
  String get onbSlide2Body =>
      'Navegue produtos, monte a lista e finalize para registar o gasto automaticamente.';

  @override
  String get onbSlide3Title => 'O seu coach financeiro IA';

  @override
  String get onbSlide3Body =>
      'Obtenha uma anÃ¡lise em 3 partes baseada no seu orÃ§amento real â€” nÃ£o conselhos genÃ©ricos.';

  @override
  String get onbSlide4Title => 'Planeie refeiÃ§Ãµes no orÃ§amento';

  @override
  String get onbSlide4Body =>
      'Gere um plano mensal ajustado ao seu orÃ§amento alimentar e agregado familiar.';

  @override
  String get onbTourSkip => 'Saltar tour';

  @override
  String get onbTourNext => 'Seguinte';

  @override
  String get onbTourDone => 'Entendido';

  @override
  String get onbTourDash1Title => 'Liquidez mensal';

  @override
  String get onbTourDash1Body =>
      'Rendimento menos todas as despesas. Verde significa saldo positivo.';

  @override
  String get onbTourDash2Title => 'Ãndice de Serenidade';

  @override
  String get onbTourDash2Body =>
      'PontuaÃ§Ã£o de saÃºde financeira 0â€“100. Toque para ver os fatores.';

  @override
  String get onbTourDash3Title => 'OrÃ§amento vs real';

  @override
  String get onbTourDash3Body => 'Gastos planeados vs reais por categoria.';

  @override
  String get onbTourDash4Title => 'Adicionar despesa';

  @override
  String get onbTourDash4Body =>
      'Toque + a qualquer momento para registar uma despesa.';

  @override
  String get onbTourDash5Title => 'NavegaÃ§Ã£o';

  @override
  String get onbTourDash5Body =>
      '5 secÃ§Ãµes: OrÃ§amento, Supermercado, Lista, Coach, RefeiÃ§Ãµes.';

  @override
  String get onbTourGrocery1Title => 'Pesquisar e filtrar';

  @override
  String get onbTourGrocery1Body =>
      'Pesquise por nome ou filtre por categoria.';

  @override
  String get onbTourGrocery2Title => 'Adicionar Ã  lista';

  @override
  String get onbTourGrocery2Body =>
      'Toque + num produto para o adicionar Ã  lista de compras.';

  @override
  String get onbTourGrocery3Title => 'Categorias';

  @override
  String get onbTourGrocery3Body =>
      'Deslize os filtros de categoria para refinar produtos.';

  @override
  String get onbTourShopping1Title => 'Riscar itens';

  @override
  String get onbTourShopping1Body =>
      'Toque num item para o marcar como apanhado.';

  @override
  String get onbTourShopping2Title => 'Finalizar compra';

  @override
  String get onbTourShopping2Body =>
      'Regista o gasto e limpa os itens marcados.';

  @override
  String get onbTourShopping3Title => 'HistÃ³rico de compras';

  @override
  String get onbTourShopping3Body =>
      'Veja todas as sessÃµes de compras anteriores aqui.';

  @override
  String get onbTourCoach1Title => 'Analisar o meu orÃ§amento';

  @override
  String get onbTourCoach1Body =>
      'Toque para gerar uma anÃ¡lise baseada nos seus dados reais.';

  @override
  String get onbTourCoach2Title => 'HistÃ³rico de anÃ¡lises';

  @override
  String get onbTourCoach2Body =>
      'As anÃ¡lises guardadas aparecem aqui, mais recentes primeiro.';

  @override
  String get onbTourMeals1Title => 'Gerar plano';

  @override
  String get onbTourMeals1Body =>
      'Cria um mÃªs completo de refeiÃ§Ãµes dentro do orÃ§amento alimentar.';

  @override
  String get onbTourMeals2Title => 'Vista semanal';

  @override
  String get onbTourMeals2Body =>
      'Navegue refeiÃ§Ãµes por semana. Toque num dia para ver a receita.';

  @override
  String get onbTourMeals3Title => 'Adicionar Ã  lista de compras';

  @override
  String get onbTourMeals3Body =>
      'Envie os ingredientes da semana para a lista com um toque.';

  @override
  String get onbTourExpenseTracker1Title => 'NavegaÃ§Ã£o mensal';

  @override
  String get onbTourExpenseTracker1Body =>
      'Alterne entre meses para ver ou adicionar despesas de qualquer perÃ­odo.';

  @override
  String get onbTourExpenseTracker2Title => 'Resumo do orÃ§amento';

  @override
  String get onbTourExpenseTracker2Body =>
      'Veja o orÃ§ado vs real e o saldo restante de relance.';

  @override
  String get onbTourExpenseTracker3Title => 'Por categoria';

  @override
  String get onbTourExpenseTracker3Body =>
      'Cada categoria mostra uma barra de progresso. Toque para expandir e ver despesas individuais.';

  @override
  String get onbTourExpenseTracker4Title => 'Adicionar despesa';

  @override
  String get onbTourExpenseTracker4Body =>
      'Toque + para registar uma nova despesa. Escolha a categoria e o valor.';

  @override
  String get onbTourSavings1Title => 'Os seus objetivos';

  @override
  String get onbTourSavings1Body =>
      'Cada cartÃ£o mostra o progresso em direÃ§Ã£o ao objetivo. Toque para ver detalhes e adicionar contribuiÃ§Ãµes.';

  @override
  String get onbTourSavings2Title => 'Criar objetivo';

  @override
  String get onbTourSavings2Body =>
      'Toque + para definir um novo objetivo de poupanÃ§a com valor alvo e prazo opcional.';

  @override
  String get onbTourRecurring1Title => 'Despesas recorrentes';

  @override
  String get onbTourRecurring1Body =>
      'Contas fixas mensais como renda, subscriÃ§Ãµes e serviÃ§os. SÃ£o incluÃ­das automaticamente no orÃ§amento.';

  @override
  String get onbTourRecurring2Title => 'Adicionar recorrente';

  @override
  String get onbTourRecurring2Body =>
      'Toque + para registar uma nova despesa recorrente com valor e dia de vencimento.';

  @override
  String get onbTourAssistant1Title => 'Assistente de comandos';

  @override
  String get onbTourAssistant1Body =>
      'O seu atalho para aÃ§Ãµes rÃ¡pidas. Toque para adicionar despesas, mudar definiÃ§Ãµes, navegar e mais â€” basta escrever o que precisa.';

  @override
  String get taxDeductionTitle => 'DeduÃ§Ãµes IRS';

  @override
  String get taxDeductionSeeDetail => 'Ver detalhe';

  @override
  String get taxDeductionEstimated => 'deduÃ§Ã£o estimada';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'MÃ¡x. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'DeduÃ§Ãµes IRS â€” Detalhe';

  @override
  String get taxDeductionDeductibleTitle => 'CATEGORIAS DEDUTÃVEIS';

  @override
  String get taxDeductionNonDeductibleTitle => 'CATEGORIAS NÃƒO DEDUTÃVEIS';

  @override
  String get taxDeductionTotalLabel => 'DEDUÃ‡ÃƒO IRS ESTIMADA';

  @override
  String taxDeductionSpent(String amount) {
    return 'Gasto: $amount';
  }

  @override
  String taxDeductionCapUsed(String percent, String cap) {
    return '$percent de $cap utilizado';
  }

  @override
  String get taxDeductionNotDeductible => 'NÃ£o dedutÃ­vel';

  @override
  String get taxDeductionDisclaimer =>
      'Estes valores sÃ£o estimativas baseadas nas despesas registadas. As deduÃ§Ãµes reais dependem das faturas registadas no e-Fatura. Consulte um profissional fiscal para valores definitivos.';

  @override
  String get settingsDashTaxDeductions => 'DeduÃ§Ãµes fiscais (PT)';

  @override
  String get settingsDashUpcomingBills => 'PrÃ³ximos pagamentos';

  @override
  String get settingsDashBudgetStreaks => 'SÃ©ries de orÃ§amento';

  @override
  String get settingsDashQuickActions => 'AÃ§Ãµes rÃ¡pidas';

  @override
  String get upcomingBillsTitle => 'PrÃ³ximos Pagamentos';

  @override
  String get upcomingBillsManage => 'Gerir';

  @override
  String get billDueToday => 'Hoje';

  @override
  String get billDueTomorrow => 'AmanhÃ£';

  @override
  String billDueInDays(int days) {
    return 'Em $days dias';
  }

  @override
  String savingsProjectionReachedBy(String date) {
    return 'Atingido atÃ© $date';
  }

  @override
  String savingsProjectionNeedPerMonth(String amount) {
    return 'Precisa $amount/mÃªs para cumprir prazo';
  }

  @override
  String get savingsProjectionOnTrack => 'No caminho certo';

  @override
  String get savingsProjectionBehind => 'Atrasado';

  @override
  String get savingsProjectionNoData =>
      'Adicione contribuiÃ§Ãµes para ver projeÃ§Ã£o';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'MÃ©dia $amount/mÃªs';
  }

  @override
  String get taxSimTitle => 'Simulador Fiscal';

  @override
  String get taxSimPresets => 'CENÃRIOS RÃPIDOS';

  @override
  String get taxSimPresetRaise => '+â‚¬200 aumento';

  @override
  String get taxSimPresetMeal => 'CartÃ£o vs dinheiro';

  @override
  String get taxSimPresetTitular => 'Ãšnico vs conjunto';

  @override
  String get taxSimParameters => 'PARÃ‚METROS';

  @override
  String get taxSimGross => 'SalÃ¡rio bruto';

  @override
  String get taxSimMarital => 'Estado civil';

  @override
  String get taxSimTitulares => 'Titulares';

  @override
  String get taxSimDependentes => 'Dependentes';

  @override
  String get taxSimMealType => 'Tipo de subsÃ­dio de alimentaÃ§Ã£o';

  @override
  String get taxSimMealAmount => 'SubsÃ­dio alim./dia';

  @override
  String get taxSimComparison => 'ATUAL VS SIMULADO';

  @override
  String get taxSimNetTakeHome => 'LÃ­quido a receber';

  @override
  String get taxSimIRS => 'RetenÃ§Ã£o IRS';

  @override
  String get taxSimSS => 'SeguranÃ§a social';

  @override
  String get taxSimDelta => 'DiferenÃ§a mensal:';

  @override
  String get taxSimButton => 'Simulador Fiscal';

  @override
  String get streakTitle => 'SÃ©ries de OrÃ§amento';

  @override
  String get streakBronze => 'Bronze';

  @override
  String get streakSilver => 'Prata';

  @override
  String get streakGold => 'Ouro';

  @override
  String get streakBronzeDesc => 'Liquidez positiva';

  @override
  String get streakSilverDesc => 'Dentro do orÃ§amento';

  @override
  String get streakGoldDesc => 'Todas as categorias';

  @override
  String streakMonths(int count) {
    return '$count meses';
  }

  @override
  String get expenseDefaultBudget => 'ORÃ‡AMENTO BASE';

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
      'Deixe vazio para usar o orÃ§amento base';

  @override
  String get settingsPersonalTip =>
      'O estado civil e dependentes afetam o escalÃ£o de IRS, que determina o imposto retido no salÃ¡rio.';

  @override
  String get settingsSalariesTip =>
      'O salÃ¡rio bruto Ã© usado para calcular o rendimento lÃ­quido apÃ³s impostos e seguranÃ§a social. Adicione vÃ¡rios salÃ¡rios se o agregado tiver mais que um rendimento.';

  @override
  String get settingsExpensesTip =>
      'Defina o orÃ§amento mensal para cada categoria. Pode ajustar para meses especÃ­ficos na vista de detalhe da categoria.';

  @override
  String get settingsMealHouseholdTip =>
      'NÃºmero de pessoas que fazem refeiÃ§Ãµes em casa. Isto ajusta receitas e porÃ§Ãµes no plano alimentar.';

  @override
  String get settingsHouseholdTip =>
      'Convide membros da famÃ­lia para partilhar dados do orÃ§amento entre dispositivos. Todos veem as mesmas despesas e orÃ§amentos.';

  @override
  String get subscriptionTitle => 'SubscriÃ§Ã£o';

  @override
  String get subscriptionFree => 'Gratuito';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get subscriptionFamily => 'FamÃ­lia';

  @override
  String get subscriptionTrialActive => 'PerÃ­odo de teste ativo';

  @override
  String subscriptionTrialDaysLeft(int count) {
    return '$count dias restantes';
  }

  @override
  String get subscriptionTrialExpired => 'PerÃ­odo de teste expirado';

  @override
  String get subscriptionUpgrade => 'Atualizar';

  @override
  String get subscriptionSeePlans => 'Ver Planos';

  @override
  String get subscriptionCurrentPlan => 'Plano Atual';

  @override
  String get subscriptionManage => 'Gerir SubscriÃ§Ã£o';

  @override
  String subscriptionFeatureExplored(int count, int total) {
    return '$count/$total funcionalidades exploradas';
  }

  @override
  String get subscriptionTrialBannerTitle => 'Teste Premium Ativo';

  @override
  String subscriptionTrialEndingSoon(int count) {
    return '$count dias restantes no seu teste!';
  }

  @override
  String get subscriptionTrialLastDay => 'Ãšltimo dia do seu teste gratuito!';

  @override
  String get subscriptionUpgradeNow => 'Atualizar Agora';

  @override
  String get subscriptionKeepData => 'Manter os Seus Dados';

  @override
  String get subscriptionCancelAnytime => 'Cancele a qualquer momento';

  @override
  String get subscriptionNoHiddenFees => 'Sem taxas ocultas';

  @override
  String get subscriptionMostPopular => 'Mais Popular';

  @override
  String subscriptionYearlySave(int percent) {
    return 'poupe $percent%';
  }

  @override
  String get subscriptionMonthly => 'Mensal';

  @override
  String get subscriptionYearly => 'Anual';

  @override
  String get subscriptionPerMonth => '/mÃªs';

  @override
  String get subscriptionPerYear => '/ano';

  @override
  String get subscriptionBilledYearly => 'faturado anualmente';

  @override
  String get subscriptionStartPremium => 'ComeÃ§ar Premium';

  @override
  String get subscriptionStartFamily => 'ComeÃ§ar FamÃ­lia';

  @override
  String get subscriptionContinueFree => 'Continuar Gratuito';

  @override
  String get subscriptionTrialEnded => 'O seu perÃ­odo de teste terminou';

  @override
  String get subscriptionChoosePlan =>
      'Escolha um plano para manter todos os seus dados e funcionalidades';

  @override
  String get subscriptionUnlockPower =>
      'Desbloqueie todo o poder do seu orÃ§amento';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature requer uma subscriÃ§Ã£o paga';
  }

  @override
  String subscriptionTryFeature(String feature) {
    return 'Experimente $feature';
  }

  @override
  String subscriptionExplore(String feature) {
    return 'Explorar $feature';
  }

  @override
  String get subtitleBatchCooking =>
      'Sugere receitas que podem ser preparadas com antecedÃªncia para vÃ¡rias refeiÃ§Ãµes';

  @override
  String get subtitleReuseLeftovers =>
      'Planeia refeiÃ§Ãµes que reutilizam ingredientes de dias anteriores';

  @override
  String get subtitleMinimizeWaste =>
      'Prioriza o uso de todos os ingredientes comprados antes de expirarem';

  @override
  String get subtitleMealTypeInclude =>
      'Incluir esta refeiÃ§Ã£o no plano semanal';

  @override
  String get subtitleShowHeroCard => 'Resumo da liquidez lÃ­quida no topo';

  @override
  String get subtitleShowStressIndex =>
      'PontuaÃ§Ã£o (0-100) que mede a pressÃ£o de despesas vs rendimento';

  @override
  String get subtitleShowMonthReview =>
      'Resumo comparativo deste mÃªs com os anteriores';

  @override
  String get subtitleShowUpcomingBills =>
      'Despesas recorrentes nos prÃ³ximos 30 dias';

  @override
  String get subtitleShowSummaryCards =>
      'Rendimento, deduÃ§Ãµes, despesas e taxa de poupanÃ§a';

  @override
  String get subtitleShowBudgetVsActual =>
      'ComparaÃ§Ã£o lado a lado por categoria de despesa';

  @override
  String get subtitleShowExpensesBreakdown =>
      'GrÃ¡fico circular de despesas por categoria';

  @override
  String get subtitleShowSavingsGoals =>
      'Progresso em relaÃ§Ã£o aos seus objetivos de poupanÃ§a';

  @override
  String get subtitleShowTaxDeductions =>
      'DeduÃ§Ãµes fiscais elegÃ­veis estimadas este ano';

  @override
  String get subtitleShowBudgetStreaks =>
      'Quantos meses consecutivos ficou dentro do orÃ§amento';

  @override
  String get subtitleShowQuickActions =>
      'Atalhos para adicionar despesas, navegar e mais';

  @override
  String get subtitleShowPurchaseHistory =>
      'Compras recentes da lista de compras e custos';

  @override
  String get subtitleShowCharts =>
      'GrÃ¡ficos de tendÃªncia de orÃ§amento, despesas e rendimento';

  @override
  String get subtitleChartExpensesPie =>
      'DistribuiÃ§Ã£o de despesas por categoria';

  @override
  String get subtitleChartIncomeVsExpenses =>
      'Rendimento mensal comparado com despesas totais';

  @override
  String get subtitleChartDeductions =>
      'DiscriminaÃ§Ã£o de despesas dedutÃ­veis nos impostos';

  @override
  String get subtitleChartNetIncome =>
      'TendÃªncia do rendimento lÃ­quido ao longo do tempo';

  @override
  String get subtitleChartSavingsRate =>
      'Percentagem de rendimento poupado por mÃªs';

  @override
  String get helperCountry =>
      'Determina o sistema fiscal, moeda e taxas de seguranÃ§a social';

  @override
  String get helperLanguage =>
      'Substituir o idioma do sistema. \"Sistema\" segue a definiÃ§Ã£o do dispositivo';

  @override
  String get helperMaritalStatus => 'Afeta o cÃ¡lculo do escalÃ£o de IRS';

  @override
  String get helperMealObjective =>
      'Define o padrÃ£o alimentar: omnÃ­voro, vegetariano, pescatariano, etc.';

  @override
  String get helperSodiumPreference =>
      'Filtra receitas pelo nÃ­vel de teor de sÃ³dio';

  @override
  String subtitleDietaryRestriction(String ingredient) {
    return 'Exclui receitas que contÃªm $ingredient';
  }

  @override
  String subtitleExcludedProtein(String protein) {
    return 'Remove $protein de todas as sugestÃµes de refeiÃ§Ãµes';
  }

  @override
  String subtitleKitchenEquipment(String equipment) {
    return 'Ativa receitas que requerem $equipment';
  }

  @override
  String get helperVeggieDays =>
      'NÃºmero de dias totalmente vegetarianos por semana';

  @override
  String get helperFishDays => 'Recomendado: 2-3 vezes por semana';

  @override
  String get helperLegumeDays => 'Recomendado: 2-3 vezes por semana';

  @override
  String get helperRedMeatDays => 'Recomendado: mÃ¡ximo 2 vezes por semana';

  @override
  String get helperMaxPrepTime =>
      'Tempo mÃ¡ximo de confeÃ§Ã£o para refeiÃ§Ãµes de semana (minutos)';

  @override
  String get helperMaxComplexity =>
      'NÃ­vel de dificuldade das receitas para dias de semana';

  @override
  String get helperWeekendPrepTime =>
      'Tempo mÃ¡ximo de confeÃ§Ã£o para refeiÃ§Ãµes de fim de semana (minutos)';

  @override
  String get helperWeekendComplexity =>
      'NÃ­vel de dificuldade das receitas para fins de semana';

  @override
  String get helperMaxBatchDays =>
      'Quantos dias uma refeiÃ§Ã£o preparada em lote pode ser reutilizada';

  @override
  String get helperNewIngredients =>
      'Limita quantos ingredientes novos aparecem por semana';

  @override
  String get helperGrossSalary =>
      'SalÃ¡rio total antes de impostos e deduÃ§Ãµes';

  @override
  String get helperExemptIncome =>
      'Rendimento adicional nÃ£o sujeito a IRS (ex.: subsÃ­dios)';

  @override
  String get helperMealAllowance =>
      'SubsÃ­dio de refeiÃ§Ã£o diÃ¡rio do empregador';

  @override
  String get helperWorkingDays =>
      'TÃ­pico: 22. Afeta o cÃ¡lculo do subsÃ­dio de refeiÃ§Ã£o';

  @override
  String get helperSalaryLabel =>
      'Um nome para identificar esta fonte de rendimento';

  @override
  String get helperExpenseAmount =>
      'Montante mensal orÃ§amentado para esta categoria';

  @override
  String get helperCalorieTarget => 'Recomendado: 2000-2500 kcal para adultos';

  @override
  String get helperProteinTarget => 'Recomendado: 50-70g para adultos';

  @override
  String get helperFiberTarget => 'Recomendado: 25-30g para adultos';

  @override
  String get infoStressIndex =>
      'Compara os gastos reais com o seu orÃ§amento. Intervalos de pontuaÃ§Ã£o:\n\n0-30: ConfortÃ¡vel - gastos bem dentro do orÃ§amento\n30-60: Moderado - a aproximar-se dos limites do orÃ§amento\n60-100: CrÃ­tico - gastos excedem significativamente o orÃ§amento';

  @override
  String get infoBudgetStreak =>
      'Meses consecutivos em que a despesa total ficou dentro do orÃ§amento total.';

  @override
  String get infoUpcomingBills =>
      'Mostra despesas recorrentes nos prÃ³ximos 30 dias com base nas suas despesas mensais.';

  @override
  String get infoSalaryBreakdown =>
      'Mostra como o salÃ¡rio bruto Ã© dividido em imposto IRS, contribuiÃ§Ãµes para a seguranÃ§a social, rendimento lÃ­quido e subsÃ­dio de refeiÃ§Ã£o.';

  @override
  String get infoBudgetVsActual =>
      'Compara o que orÃ§amentou por categoria com o que realmente gastou. Verde significa abaixo do orÃ§amento, vermelho significa acima do orÃ§amento.';

  @override
  String get infoSavingsGoals =>
      'Progresso em relaÃ§Ã£o a cada objetivo de poupanÃ§a com base nas contribuiÃ§Ãµes efetuadas.';

  @override
  String get infoTaxDeductions =>
      'Despesas dedutÃ­veis estimadas (saÃºde, educaÃ§Ã£o, habitaÃ§Ã£o). Estas sÃ£o apenas estimativas - consulte um profissional fiscal para valores precisos.';

  @override
  String get infoPurchaseHistory =>
      'Total gasto em compras da lista de compras este mÃªs.';

  @override
  String get infoExpensesBreakdown =>
      'DiscriminaÃ§Ã£o visual das suas despesas por categoria no mÃªs atual.';

  @override
  String get infoCharts =>
      'Dados de tendÃªncia ao longo do tempo. Toque em qualquer grÃ¡fico para uma vista detalhada.';

  @override
  String get infoExpenseTrackerSummary =>
      'OrÃ§amentado = despesa mensal planeada. Real = o que gastou atÃ© agora. Restante = orÃ§amento menos real.';

  @override
  String get infoExpenseTrackerProgress =>
      'Verde: abaixo de 75% do orÃ§amento. Amarelo: 75-100%. Vermelho: acima do orÃ§amento.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filtre despesas por texto, categoria ou intervalo de datas.';

  @override
  String get infoSavingsProjection =>
      'Baseado nas suas contribuiÃ§Ãµes mensais mÃ©dias. \"No caminho certo\" significa que o ritmo atual atinge o objetivo no prazo. \"Atrasado\" significa que precisa de aumentar as contribuiÃ§Ãµes.';

  @override
  String get infoSavingsRequired =>
      'O montante que precisa de poupar por mÃªs a partir de agora para atingir o objetivo no prazo.';

  @override
  String get infoCoachModes =>
      'Eco: gratuito, sem memÃ³ria de conversa.\nPlus: 1 crÃ©dito por mensagem, lembra as Ãºltimas 5 mensagens.\nPro: 2 crÃ©ditos por mensagem, memÃ³ria de conversa completa.';

  @override
  String get infoCoachCredits =>
      'Os crÃ©ditos sÃ£o usados nos modos Plus e Pro. Recebe crÃ©ditos iniciais ao registar-se. O modo Eco Ã© sempre gratuito.';

  @override
  String get helperWizardGrossSalary =>
      'O seu salÃ¡rio mensal total antes de impostos';

  @override
  String get helperWizardMealAllowance =>
      'SubsÃ­dio de refeiÃ§Ã£o diÃ¡rio do empregador (se aplicÃ¡vel)';

  @override
  String get helperWizardRent => 'Pagamento mensal de habitaÃ§Ã£o';

  @override
  String get helperWizardGroceries =>
      'OrÃ§amento mensal de alimentaÃ§Ã£o e produtos domÃ©sticos';

  @override
  String get helperWizardTransport =>
      'Custos mensais de transporte (combustÃ­vel, transportes pÃºblicos, etc.)';

  @override
  String get helperWizardUtilities => 'Eletricidade, Ã¡gua e gÃ¡s mensais';

  @override
  String get helperWizardTelecom => 'Internet, telefone e TV mensais';

  @override
  String get savingsGoalHowItWorksTitle => 'Como funciona?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Crie um objetivo com um nome e o valor que pretende atingir (ex: \"FÃ©rias â€” 2 000 â‚¬\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Opcionalmente defina uma data limite para ter um prazo de referÃªncia.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Sempre que poupar dinheiro, toque no objetivo e registe uma contribuiÃ§Ã£o com o valor e a data.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Acompanhe o progresso: a barra mostra quanto jÃ¡ poupou e a projeÃ§Ã£o estima quando atingirÃ¡ o objetivo.';

  @override
  String get savingsGoalDashboardHint =>
      'Toque num objetivo para ver detalhes e registar contribuiÃ§Ãµes.';

  @override
  String get rateLimitMessage =>
      'Por favor, aguarde um momento antes de tentar novamente';

  @override
  String get planningExportTitle => 'Exportar';

  @override
  String get planningImportTitle => 'Importar';

  @override
  String get planningExportShoppingList => 'Exportar lista de compras';

  @override
  String get planningImportShoppingList => 'Importar lista de compras';

  @override
  String get planningExportMealPlan => 'Exportar plano de refeiÃ§Ãµes';

  @override
  String get planningImportMealPlan => 'Importar plano de refeiÃ§Ãµes';

  @override
  String get planningExportPantry => 'Exportar despensa';

  @override
  String get planningImportPantry => 'Importar despensa';

  @override
  String get planningExportFreeformMeals => 'Exportar refeiÃ§Ãµes livres';

  @override
  String get planningImportFreeformMeals => 'Importar refeiÃ§Ãµes livres';

  @override
  String get planningFormatCsv => 'CSV';

  @override
  String get planningFormatJson => 'JSON';

  @override
  String get planningImportSuccess => 'Importado com sucesso';

  @override
  String planningImportError(String error) {
    return 'ImportaÃ§Ã£o falhou: $error';
  }

  @override
  String get planningExportSuccess => 'Exportado com sucesso';

  @override
  String get planningDataPortability => 'Portabilidade de dados';

  @override
  String get planningDataPortabilityDesc =>
      'Importar e exportar artefactos de planeamento';

  @override
  String get mealBudgetInsightTitle => 'VisÃ£o do OrÃ§amento';

  @override
  String get mealBudgetStatusSafe => 'No caminho';

  @override
  String get mealBudgetStatusWatch => 'AtenÃ§Ã£o';

  @override
  String get mealBudgetStatusOver => 'Acima do orÃ§amento';

  @override
  String get mealBudgetWeeklyCost => 'Custo semanal estimado';

  @override
  String get mealBudgetProjectedMonthly => 'ProjeÃ§Ã£o mensal';

  @override
  String get mealBudgetMonthlyBudget => 'OrÃ§amento mensal de alimentaÃ§Ã£o';

  @override
  String get mealBudgetRemaining => 'OrÃ§amento restante';

  @override
  String get mealBudgetTopExpensive => 'RefeiÃ§Ãµes mais caras';

  @override
  String get mealBudgetSuggestedSwaps => 'Trocas mais baratas sugeridas';

  @override
  String get mealBudgetViewDetails => 'Ver detalhes';

  @override
  String get mealBudgetApplySwap => 'Aplicar';

  @override
  String mealBudgetSwapSavings(String amount) {
    return 'Poupa $amount';
  }

  @override
  String get mealBudgetDailyBreakdown => 'Custo diÃ¡rio detalhado';

  @override
  String get mealBudgetShoppingImpact => 'Impacto nas compras';

  @override
  String get mealBudgetUniqueIngredients => 'Ingredientes Ãºnicos';

  @override
  String get mealBudgetEstShoppingCost => 'Custo estimado de compras';

  @override
  String get productUpdatesTitle => 'Novidades do Produto';

  @override
  String get whatsNewTab => 'Novidades';

  @override
  String get roadmapTab => 'Roteiro';

  @override
  String get noUpdatesYet => 'Sem novidades ainda';

  @override
  String get noRoadmapItems => 'Sem itens no roteiro ainda';

  @override
  String get roadmapNow => 'Agora';

  @override
  String get roadmapNext => 'Em breve';

  @override
  String get roadmapLater => 'Mais tarde';

  @override
  String get productUpdatesSubtitle => 'Changelog e funcionalidades futuras';

  @override
  String get whatsNewDialogTitle => 'Novidades';

  @override
  String get whatsNewDialogDismiss => 'Entendi';

  @override
  String get confidenceCenterTitle => 'Centro de ConfianÃ§a';

  @override
  String get confidenceSyncHealth => 'Estado de SincronizaÃ§Ã£o';

  @override
  String get confidenceDataAlerts => 'Alertas de Qualidade dos Dados';

  @override
  String get confidenceRecommendedActions => 'AÃ§Ãµes Recomendadas';

  @override
  String get confidenceCenterSubtitle =>
      'Frescura dos dados e saÃºde do sistema';

  @override
  String get confidenceCenterTile => 'Centro de ConfianÃ§a';

  @override
  String get pantryPickerTitle => 'Selecionar Despensa';

  @override
  String get pantrySearchHint => 'Pesquisar ingredientes...';

  @override
  String get pantryTabAlwaysHave => 'Sempre Tenho';

  @override
  String get pantryTabThisWeek => 'Esta Semana';

  @override
  String pantrySummaryLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens na despensa',
      one: '1 item na despensa',
    );
    return '$_temp0';
  }

  @override
  String get pantryEdit => 'Editar';

  @override
  String get pantryUseWhatWeHave => 'Usar o Que Temos';

  @override
  String get pantryMarkAtHome => 'JÃ¡ tenho em casa';

  @override
  String get pantryHaveIt => 'Tenho';

  @override
  String pantryCoverageLabel(int pct) {
    return '$pct% coberto pela despensa';
  }

  @override
  String get pantryStaples => 'ESSENCIAIS (SEMPRE EM STOCK)';

  @override
  String get pantryWeekly => 'DESPENSA DESTA SEMANA';

  @override
  String pantryAddedToWeekly(String name) {
    return '$name adicionado Ã  despensa semanal';
  }

  @override
  String pantryRemovedFromList(String name) {
    return '$name removido da lista (jÃ¡ em casa)';
  }

  @override
  String pantryMarkedAtHome(String name) {
    return '$name marcado como jÃ¡ em casa';
  }

  @override
  String get householdActivityTitle => 'Atividade do Agregado';

  @override
  String get householdActivityFilterAll => 'Tudo';

  @override
  String get householdActivityFilterShopping => 'Compras';

  @override
  String get householdActivityFilterMeals => 'RefeiÃ§Ãµes';

  @override
  String get householdActivityFilterExpenses => 'Despesas';

  @override
  String get householdActivityFilterPantry => 'Despensa';

  @override
  String get householdActivityFilterSettings => 'DefiniÃ§Ãµes';

  @override
  String get householdActivityEmpty => 'Sem atividade';

  @override
  String get householdActivityEmptyMessage =>
      'As aÃ§Ãµes partilhadas do seu agregado aparecerÃ£o aqui.';

  @override
  String get householdActivityToday => 'HOJE';

  @override
  String get householdActivityYesterday => 'ONTEM';

  @override
  String get householdActivityThisWeek => 'ESTA SEMANA';

  @override
  String get householdActivityOlder => 'ANTERIORES';

  @override
  String get householdActivityJustNow => 'Agora mesmo';

  @override
  String householdActivityMinutesAgo(int count) {
    return '$count min atrÃ¡s';
  }

  @override
  String householdActivityHoursAgo(int count) {
    return '${count}h atrÃ¡s';
  }

  @override
  String householdActivityDaysAgo(int count) {
    return '${count}d atrÃ¡s';
  }

  @override
  String householdActivityAddedBy(String name) {
    return 'Adicionado por $name';
  }

  @override
  String householdActivityRemovedBy(String name) {
    return 'Removido por $name';
  }

  @override
  String householdActivitySwappedBy(String name) {
    return 'Trocado por $name';
  }

  @override
  String householdActivityUpdatedBy(String name) {
    return 'Atualizado por $name';
  }

  @override
  String householdActivityCheckedBy(String name) {
    return 'Marcado por $name';
  }

  @override
  String get barcodeScanTitle => 'Ler Codigo de Barras';

  @override
  String get barcodeScanHint => 'Aponte a camera para um codigo de barras';

  @override
  String get barcodeScanTooltip => 'Ler codigo de barras';

  @override
  String get barcodeProductFound => 'Produto Encontrado';

  @override
  String get barcodeProductNotFound => 'Produto Nao Encontrado';

  @override
  String get barcodeLabel => 'Codigo de barras';

  @override
  String get barcodeAddToList => 'Adicionar a Lista';

  @override
  String get barcodeManualEntry =>
      'Nenhum produto encontrado. Insira os dados manualmente:';

  @override
  String get barcodeProductName => 'Nome do produto';

  @override
  String get barcodePrice => 'Preco';

  @override
  String barcodeAddedToList(String name) {
    return '$name adicionado a lista de compras';
  }

  @override
  String get barcodeInvoiceDetected =>
      'Este Ã© um cÃ³digo de fatura, nÃ£o de produto';

  @override
  String get barcodeInvoiceAction => 'Abrir Scanner de Recibos';

  @override
  String get quickAddTooltip => 'AÃ§Ãµes rÃ¡pidas';

  @override
  String get quickAddExpense => 'Adicionar despesa';

  @override
  String get quickAddShopping => 'Adicionar item de compras';

  @override
  String get quickOpenMeals => 'Planeador de refeiÃ§Ãµes';

  @override
  String get quickOpenAssistant => 'Assistente';

  @override
  String get freeformBadge => 'Livre';

  @override
  String get freeformCreateTitle => 'Adicionar refeiÃ§Ã£o livre';

  @override
  String get freeformEditTitle => 'Editar refeiÃ§Ã£o livre';

  @override
  String get freeformTitleLabel => 'TÃ­tulo da refeiÃ§Ã£o';

  @override
  String get freeformTitleHint => 'ex. Sobras, Pizza de takeaway';

  @override
  String get freeformNoteLabel => 'Nota (opcional)';

  @override
  String get freeformNoteHint => 'Detalhes sobre esta refeiÃ§Ã£o';

  @override
  String get freeformCostLabel => 'Custo estimado (opcional)';

  @override
  String get freeformTagsLabel => 'Etiquetas';

  @override
  String get freeformTagLeftovers => 'Sobras';

  @override
  String get freeformTagPantryMeal => 'Despensa';

  @override
  String get freeformTagTakeout => 'Takeaway';

  @override
  String get freeformTagQuickMeal => 'RefeiÃ§Ã£o rÃ¡pida';

  @override
  String get freeformShoppingItemsLabel => 'Itens de compras';

  @override
  String get freeformAddItem => 'Adicionar item';

  @override
  String get freeformItemName => 'Nome do item';

  @override
  String get freeformItemQuantity => 'Quantidade';

  @override
  String get freeformItemUnit => 'Unidade';

  @override
  String get freeformItemPrice => 'PreÃ§o est.';

  @override
  String get freeformItemStore => 'Loja';

  @override
  String freeformShoppingItemCount(int count) {
    return '$count itens de compras';
  }

  @override
  String get freeformAddToSlot => 'Adicionar refeiÃ§Ã£o livre';

  @override
  String get freeformReplace => 'Substituir por refeiÃ§Ã£o livre';

  @override
  String get insightsTitle => 'AnÃ¡lise';

  @override
  String get insightsAnalyzeSpending => 'Analisar gastos ao longo do tempo';

  @override
  String get insightsTrackProgress => 'Acompanhar progresso das metas';

  @override
  String get insightsTaxOutcome => 'Estimar resultado fiscal anual';

  @override
  String get moreTitle => 'Mais';

  @override
  String get moreDetailedDashboard => 'Painel Detalhado';

  @override
  String get moreDetailedDashboardSubtitle =>
      'Abrir painel financeiro completo com todos os cartÃµes';

  @override
  String get moreSavingsSubtitle =>
      'Acompanhar e atualizar o progresso das metas';

  @override
  String get moreNotificationsSubtitle => 'OrÃ§amentos, contas e lembretes';

  @override
  String get moreSettingsSubtitle => 'PreferÃªncias, perfil e painel';

  @override
  String get morePlanFree => 'Plano GrÃ¡tis';

  @override
  String get morePlanTrial => 'PerÃ­odo de Teste Ativo';

  @override
  String get morePlanPro => 'Plano Pro';

  @override
  String get morePlanFamily => 'Plano FamÃ­lia';

  @override
  String get morePlanManage => 'Gerir o teu plano e faturaÃ§Ã£o';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categorias • $goals meta de poupanÃ§a';
  }

  @override
  String moreItemsPaused(int count) {
    return '$count itens pausados';
  }

  @override
  String get moreUpgrade => 'Upgrade →';

  @override
  String get planTitle => 'Planear';

  @override
  String get planGrocerySubtitle => 'Explorar produtos e preÃ§os';

  @override
  String get planShoppingList => 'Lista de Compras';

  @override
  String get planShoppingSubtitle => 'Rever e finalizar compras';

  @override
  String get planMealSubtitle => 'Gerar planos semanais acessÃ­veis';

  @override
  String coachActiveMemory(String mode, int percent) {
    return 'MemÃ³ria ativa: $mode ($percent%)';
  }

  @override
  String get coachCostPerMessageNote =>
      'Custo por mensagem enviada. A resposta do coach nÃ£o consome crÃ©ditos.';

  @override
  String get coachExpandTip => 'Expandir aviso';

  @override
  String get coachCollapseTip => 'Minimizar aviso';

  @override
  String featureTryName(String name) {
    return 'Experimentar $name';
  }

  @override
  String featureExploreName(String name) {
    return 'Explorar $name';
  }

  @override
  String featureRequiresPremium(String name) {
    return '$name requer Premium';
  }

  @override
  String get featureTapToUpgrade => 'Toca para fazer upgrade';

  @override
  String get featureNameAiCoach => 'Coach IA';

  @override
  String get featureNameMealPlanner => 'Planeador de RefeiÃ§Ãµes';

  @override
  String get featureNameExpenseTracker => 'Rastreador de Despesas';

  @override
  String get featureNameSavingsGoals => 'Metas de PoupanÃ§a';

  @override
  String get featureNameShoppingList => 'Lista de Compras';

  @override
  String get featureNameGroceryBrowser => 'Explorador de Produtos';

  @override
  String get featureNameExportReports => 'Exportar RelatÃ³rios';

  @override
  String get featureNameTaxSimulator => 'Simulador Fiscal';

  @override
  String get featureNameDashboard => 'Painel';

  @override
  String get featureTagAiCoach => 'O teu consultor financeiro pessoal';

  @override
  String get featureTagMealPlanner => 'Poupa dinheiro na alimentaÃ§Ã£o';

  @override
  String get featureTagExpenseTracker => 'Sabe para onde vai cada euro';

  @override
  String get featureTagSavingsGoals => 'Concretiza os teus sonhos';

  @override
  String get featureTagShoppingList => 'Compra de forma mais inteligente';

  @override
  String get featureTagGroceryBrowser => 'Compara preÃ§os instantaneamente';

  @override
  String get featureTagExportReports =>
      'RelatÃ³rios profissionais de orÃ§amento';

  @override
  String get featureTagTaxSimulator => 'Planeamento fiscal multi-paÃ­s';

  @override
  String get featureTagDashboard => 'A tua visÃ£o financeira geral';

  @override
  String get featureDescAiCoach =>
      'ObtÃ©m insights personalizados sobre os teus hÃ¡bitos de gastos, dicas de poupanÃ§a e otimizaÃ§Ã£o do orÃ§amento com IA.';

  @override
  String get featureDescMealPlanner =>
      'Planeia refeiÃ§Ãµes semanais dentro do teu orÃ§amento. A IA gera receitas com base nas tuas preferÃªncias e necessidades alimentares.';

  @override
  String get featureDescExpenseTracker =>
      'Acompanha despesas reais vs. orÃ§amento em tempo real. VÃª onde gastas demais e onde podes poupar.';

  @override
  String get featureDescSavingsGoals =>
      'Define metas de poupanÃ§a com prazos, acompanha contribuiÃ§Ãµes e vÃª projeÃ§Ãµes de quando atingirÃ¡s os teus objetivos.';

  @override
  String get featureDescShoppingList =>
      'Cria listas de compras partilhadas em tempo real. Marca itens enquanto compras, finaliza e acompanha gastos.';

  @override
  String get featureDescGroceryBrowser =>
      'Explora produtos de vÃ¡rias lojas, compara preÃ§os e adiciona as melhores ofertas diretamente Ã  tua lista de compras.';

  @override
  String get featureDescExportReports =>
      'Exporta o teu orÃ§amento, despesas e resumos financeiros em PDF ou CSV para os teus registos ou contabilista.';

  @override
  String get featureDescTaxSimulator =>
      'Compara obrigaÃ§Ãµes fiscais entre paÃ­ses. Perfeito para expatriados e quem considera mudanÃ§a de paÃ­s.';

  @override
  String get featureDescDashboard =>
      'VÃª o resumo completo do orÃ§amento, grÃ¡ficos e saÃºde financeira de relance.';

  @override
  String get trialPremiumActive => 'PerÃ­odo de Teste Premium Ativo';

  @override
  String get trialHalfway => 'O teu perÃ­odo de teste estÃ¡ a meio';

  @override
  String trialDaysLeftInTrial(int count) {
    return '$count dias restantes no teu perÃ­odo de teste!';
  }

  @override
  String get trialLastDay => 'Ãšltimo dia do teu perÃ­odo de teste grÃ¡tis!';

  @override
  String get trialSeePlans => 'Ver Planos';

  @override
  String get trialUpgradeNow => 'Upgrade Agora — MantÃ©m os Teus Dados';

  @override
  String get trialSubtitleUrgent =>
      'O teu acesso premium termina em breve. Faz upgrade para manter o Coach IA, Planeador de RefeiÃ§Ãµes e todos os teus dados.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'JÃ¡ experimentaste o $name? Aproveita ao mÃ¡ximo o teu perÃ­odo de teste!';
  }

  @override
  String get trialSubtitleMidProgress =>
      'EstÃ¡s a fazer Ã³timo progresso! Continua a explorar funcionalidades premium.';

  @override
  String get trialSubtitleEarly =>
      'Tens acesso total a todas as funcionalidades premium. Explora tudo!';

  @override
  String trialFeaturesExplored(int explored, int total) {
    return '$explored/$total funcionalidades exploradas';
  }

  @override
  String trialDaysRemaining(int count) {
    return '$count dias restantes';
  }

  @override
  String trialProgressLabel(int percent) {
    return 'Progresso do teste $percent%';
  }

  @override
  String get featureNameAiCoachFull => 'Coach Financeiro IA';

  @override
  String get receiptScanTitle => 'Scan Recibo';

  @override
  String get receiptScanQrMode => 'QR Code';

  @override
  String get receiptScanPhotoMode => 'Foto';

  @override
  String get receiptScanHint => 'Aponte a cÃ¢mara para o QR code do recibo';

  @override
  String get receiptScanPhotoHint =>
      'Posicione o recibo e toque no botÃ£o para capturar';

  @override
  String get receiptScanProcessing => 'A ler reciboâ€¦';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Despesa de $amount no $store registada';
  }

  @override
  String get receiptScanFailed => 'NÃ£o foi possÃ­vel ler o recibo';

  @override
  String get receiptScanPrompt =>
      'Compras feitas? Scan o recibo para registar despesa automaticamente.';

  @override
  String get receiptMerchantUnknown => 'Loja desconhecida';

  @override
  String receiptMerchantNamePrompt(String nif) {
    return 'Insira o nome da loja para NIF $nif';
  }

  @override
  String receiptItemsMatched(int count) {
    return '$count itens associados Ã  lista de compras';
  }

  @override
  String get quickScanReceipt => 'Scan Recibo';

  @override
  String get receiptReviewTitle => 'Rever Recibo';

  @override
  String get receiptReviewMerchant => 'Loja';

  @override
  String get receiptReviewDate => 'Data';

  @override
  String get receiptReviewTotal => 'Total';

  @override
  String get receiptReviewCategory => 'Categoria';

  @override
  String receiptReviewItems(int count) {
    return '$count itens detetados';
  }

  @override
  String get receiptReviewConfirm => 'Adicionar Despesa';

  @override
  String get receiptReviewRetake => 'Repetir';

  @override
  String get receiptCameraPermissionTitle => 'Acesso Ã  CÃ¢mara';

  @override
  String get receiptCameraPermissionBody =>
      'Ã‰ necessÃ¡rio acesso Ã  cÃ¢mara para digitalizar recibos e cÃ³digos de barras.';

  @override
  String get receiptCameraPermissionAllow => 'Permitir';

  @override
  String get receiptCameraPermissionDeny => 'Agora nÃ£o';

  @override
  String get receiptCameraBlockedTitle => 'CÃ¢mara Bloqueada';

  @override
  String get receiptCameraBlockedBody =>
      'A permissÃ£o da cÃ¢mara foi negada permanentemente. Abra as definiÃ§Ãµes para a ativar.';

  @override
  String get receiptCameraBlockedSettings => 'Abrir DefiniÃ§Ãµes';

  @override
  String groceryMarketData(String marketCode) {
    return 'Dados do mercado $marketCode';
  }

  @override
  String groceryStoreCoverage(int active, int total) {
    return '$active lojas ativas em $total';
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
    return '$count falhada';
  }

  @override
  String get groceryHideStaleStores => 'Esconder lojas desatualizadas';

  @override
  String groceryComparisonsFreshOnly(int count) {
    return 'A mostrar $count loja fresca nas comparações';
  }

  @override
  String get navHome => 'InÃ­cio';

  @override
  String get navHomeTip => 'Resumo mensal';

  @override
  String get navTrack => 'Despesas';

  @override
  String get navTrackTip => 'Registar despesas mensais';

  @override
  String get navPlan => 'Planear';

  @override
  String get navPlanTip => 'Mercearia, lista e plano de refeiÃ§Ãµes';

  @override
  String get navPlanAndShop => 'Compras';

  @override
  String get navPlanAndShopTip => 'Lista de compras, mercearia e refeiÃ§Ãµes';

  @override
  String get navMore => 'Mais';

  @override
  String get navMoreTip => 'DefiniÃ§Ãµes e anÃ¡lises';

  @override
  String get paywallContinueFree => 'A continuar com o plano gratuito';

  @override
  String get paywallUpgradedPro => 'Atualizado para Pro â€” obrigado!';

  @override
  String get paywallNoRestore => 'Nenhuma compra anterior encontrada';

  @override
  String get paywallRestoredPro => 'SubscriÃ§Ã£o Pro restaurada!';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Teste ($count dias restantes)';
  }

  @override
  String get authConnectionError => 'Erro de ligaÃ§Ã£o';

  @override
  String get authRetry => 'Tentar novamente';

  @override
  String get authSignOut => 'Terminar sessÃ£o';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get settingsGroupAccount => 'CONTA';

  @override
  String get settingsGroupBudget => 'ORÃ‡AMENTO';

  @override
  String get settingsGroupPreferences => 'PREFERÃŠNCIAS';

  @override
  String get settingsGroupAdvanced => 'AVANÃ‡ADO';

  @override
  String get settingsManageSubscription => 'Gerir SubscriÃ§Ã£o';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get mealShowDetails => 'Mostrar detalhes';

  @override
  String get mealHideDetails => 'Ocultar detalhes';

  @override
  String get taxSimTitularesHint =>
      'NÃºmero de titulares de rendimento no agregado familiar';

  @override
  String get taxSimMealTypeHint =>
      'CartÃ£o: isento de imposto atÃ© ao limite legal. Dinheiro: tributado como rendimento.';

  @override
  String get taxSimIRSFull => 'IRS (Imposto sobre o Rendimento) retenÃ§Ã£o';

  @override
  String get taxSimSSFull => 'SS (SeguranÃ§a Social)';

  @override
  String get stressZoneCritical =>
      '0â€“39: PressÃ£o financeira elevada, aÃ§Ã£o urgente necessÃ¡ria';

  @override
  String get stressZoneWarning =>
      '40â€“59: Alguns riscos presentes, melhorias recomendadas';

  @override
  String get stressZoneGood =>
      '60â€“79: FinanÃ§as saudÃ¡veis, pequenas otimizaÃ§Ãµes possÃ­veis';

  @override
  String get stressZoneExcellent =>
      '80â€“100: PosiÃ§Ã£o financeira forte, bem gerida';

  @override
  String get projectionStressHint =>
      'Como este cenÃ¡rio de gastos afeta a sua pontuaÃ§Ã£o geral de saÃºde financeira (0â€“100)';

  @override
  String get coachWelcomeTitle => 'O Seu Coach Financeiro IA';

  @override
  String get coachWelcomeBody =>
      'FaÃ§a perguntas sobre o seu orÃ§amento, despesas ou poupanÃ§as. O coach analisa os seus dados financeiros reais para dar conselhos personalizados.';

  @override
  String get coachWelcomeCredits =>
      'Os crÃ©ditos sÃ£o usados nos modos Plus e Pro. O modo Eco Ã© sempre gratuito.';

  @override
  String get coachWelcomeRateLimit =>
      'Para garantir respostas de qualidade, existe um breve intervalo entre mensagens.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Comprar crÃ©ditos';

  @override
  String get coachContinueEco => 'Continuar com Eco';

  @override
  String get coachAchieved => 'Consegui!';

  @override
  String get coachNotYet => 'Ainda nÃ£o';

  @override
  String coachCreditsAdded(int count) {
    return '+$count crÃ©ditos adicionados';
  }

  @override
  String coachPurchaseError(String error) {
    return 'Erro na compra: $error';
  }

  @override
  String coachUseMode(String mode) {
    return 'Usar $mode';
  }

  @override
  String coachKeepMode(String mode) {
    return 'Manter $mode';
  }

  @override
  String savingsGoalSaveError(String error) {
    return 'Erro ao guardar objetivo: $error';
  }

  @override
  String savingsGoalDeleteError(String error) {
    return 'Erro ao eliminar objetivo: $error';
  }

  @override
  String savingsGoalUpdateError(String error) {
    return 'Erro ao atualizar objetivo: $error';
  }

  @override
  String get settingsSubscription => 'SubscriÃ§Ã£o';

  @override
  String get settingsSubscriptionFree => 'Gratuito';

  @override
  String settingsActiveCategoriesCount(int active, int total) {
    return 'Categorias Ativas ($active de $total)';
  }

  @override
  String get settingsPausedCategories => 'Categorias Pausadas';

  @override
  String get settingsOpenDashboard => 'Abrir Dashboard Detalhado';

  @override
  String get settingsAssistantGroup => 'ASSISTENTE';

  @override
  String get settingsAiCoach => 'Coach IA';

  @override
  String get setupWizardSubsidyLabel => 'DUODÃ‰CIMOS';

  @override
  String get setupWizardPerDay => '/dia';

  @override
  String get configurationError => 'Erro de ConfiguraÃ§Ã£o';

  @override
  String get confidenceAllHealthy =>
      'Todos os sistemas saudÃ¡veis. Nenhuma aÃ§Ã£o necessÃ¡ria.';

  @override
  String get confidenceNoAlerts => 'Sem alertas. Tudo em ordem.';

  @override
  String get onbSwipeHint => 'Deslize para continuar';

  @override
  String onbSlideOf(int current, int total) {
    return 'Slide $current de $total';
  }

  @override
  String get expenseTrendsChartLabel =>
      'GrÃ¡fico de tendÃªncias de despesas mostrando orÃ§amento versus gastos reais';

  @override
  String get customCategories => 'Categorias';

  @override
  String get customCategoryAdd => 'Adicionar Categoria';

  @override
  String get customCategoryEdit => 'Editar Categoria';

  @override
  String get customCategoryDelete => 'Eliminar Categoria';

  @override
  String get customCategoryDeleteConfirm => 'Eliminar esta categoria?';

  @override
  String get customCategoryName => 'Nome da categoria';

  @override
  String get customCategoryIcon => 'Ãcone';

  @override
  String get customCategoryColor => 'Cor';

  @override
  String get customCategoryEmpty => 'Sem categorias personalizadas';

  @override
  String get customCategorySaved => 'Categoria guardada';

  @override
  String get customCategoryInUse => 'Categoria em uso, nÃ£o pode ser eliminada';

  @override
  String get customCategoryPredefinedHint =>
      'Categorias predefinidas usadas em toda a aplicaÃ§Ã£o';

  @override
  String get customCategoryDefault => 'Predefinida';

  @override
  String get expenseLocationPermissionDenied =>
      'PermissÃ£o de localizaÃ§Ã£o negada';

  @override
  String get expenseAttachPhoto => 'Anexar Foto';

  @override
  String get expenseAttachCamera => 'CÃ¢mara';

  @override
  String get expenseAttachGallery => 'Galeria';

  @override
  String get expenseAttachUploadFailed =>
      'Falha ao carregar anexos. Verifique a sua ligaÃ§Ã£o.';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Detetar localizaÃ§Ã£o';

  @override
  String get biometricLockTitle => 'Bloqueio da App';

  @override
  String get biometricLockSubtitle =>
      'Exigir autenticaÃ§Ã£o ao abrir a aplicaÃ§Ã£o';

  @override
  String get biometricPrompt => 'Autentique-se para continuar';

  @override
  String get biometricReason =>
      'Verifique a sua identidade para desbloquear a aplicaÃ§Ã£o';

  @override
  String get biometricRetry => 'Tentar Novamente';

  @override
  String get notifDailyExpenseReminder => 'Lembrete diÃ¡rio de despesas';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Lembra-o de registar as despesas do dia';

  @override
  String get notifDailyExpenseTitle => 'NÃ£o se esqueÃ§a das despesas!';

  @override
  String get notifDailyExpenseBody =>
      'Reserve um momento para registar as despesas de hoje';

  @override
  String get settingsSalaryLabelHint => 'ex: Emprego principal, Freelance';

  @override
  String get settingsExpenseNameLabel => 'NOME DA DESPESA';

  @override
  String get settingsCategoryLabel => 'CATEGORIA';

  @override
  String get settingsMonthlyBudgetLabel => 'ORÃ‡AMENTO MENSAL';

  @override
  String get expenseLocationSearch => 'Pesquisar';

  @override
  String get expenseLocationSearchHint => 'Pesquisar endereÃ§o...';

  @override
  String get dashboardBurnRateTitle => 'Velocidade de Gasto';

  @override
  String get dashboardBurnRateSubtitle =>
      'MÃ©dia diÃ¡ria vs orÃ§amento disponÃ­vel';

  @override
  String get dashboardBurnRateOnTrack => 'No caminho';

  @override
  String get dashboardBurnRateOver => 'Acima do ritmo';

  @override
  String get dashboardBurnRateDailyAvg => 'MÃ‰DIA/DIA';

  @override
  String get dashboardBurnRateAllowance => 'DISP./DIA';

  @override
  String get dashboardBurnRateDaysLeft => 'DIAS RESTANTES';

  @override
  String get dashboardTopCategoriesTitle => 'Top Categorias';

  @override
  String get dashboardTopCategoriesSubtitle =>
      'Categorias com mais despesas este mÃªs';

  @override
  String get dashboardCashFlowTitle => 'PrevisÃ£o de Fluxo';

  @override
  String get dashboardCashFlowSubtitle =>
      'ProjeÃ§Ã£o de saldo atÃ© ao fim do mÃªs';

  @override
  String get dashboardCashFlowProjectedSpend => 'GASTO PROJETADO';

  @override
  String get dashboardCashFlowEndOfMonth => 'FIM DO MÃŠS';

  @override
  String dashboardCashFlowPendingBills(String amount) {
    return 'Contas pendentes: $amount';
  }

  @override
  String get dashboardSavingsRateTitle => 'Taxa de PoupanÃ§a';

  @override
  String get dashboardSavingsRateSubtitle =>
      'Percentagem do rendimento poupada';

  @override
  String dashboardSavingsRateSaved(String amount) {
    return 'Poupado este mÃªs: $amount';
  }

  @override
  String get dashboardCoachInsightTitle => 'Dica Financeira';

  @override
  String get dashboardCoachInsightSubtitle =>
      'SugestÃ£o personalizada do assistente financeiro';

  @override
  String get dashboardCoachLowSavings =>
      'A sua taxa de poupanÃ§a estÃ¡ abaixo de 10%. Identifique uma despesa que pode reduzir este mÃªs.';

  @override
  String get dashboardCoachHighSpending =>
      'Os gastos estÃ£o a aproximar-se do rendimento. Reveja as despesas nÃ£o essenciais.';

  @override
  String get dashboardCoachGoodSavings =>
      'Excelente! EstÃ¡ a poupar mais de 20%. Continue assim!';

  @override
  String get dashboardCoachGeneral =>
      'Toque para obter anÃ¡lises personalizadas do seu orÃ§amento.';

  @override
  String get dashGroupInsights => 'AnÃ¡lise';

  @override
  String get dashReorderHint => 'Arraste para reordenar os cartÃµes';

  @override
  String get settingsSalarySummaryGross => 'Bruto';

  @override
  String get settingsSalarySummaryNet => 'LÃ­quido';

  @override
  String get settingsDeductionIrs => 'IRS';

  @override
  String get settingsDeductionSs => 'SS';

  @override
  String get settingsDeductionMeal => 'Sub. Alim.';

  @override
  String settingsMealMonthlyTotal(String amount) {
    return 'Total mensal: $amount';
  }

  @override
  String get mealSubstituteIngredient => 'Substituir ingrediente';

  @override
  String mealSubstituteTitle(String name) {
    return 'Substituir $name';
  }

  @override
  String mealSubstitutionApplied(String oldName, String newName) {
    return '$oldName substituÃ­do por $newName';
  }

  @override
  String get mealSubstitutionAdapting => 'A adaptar receita...';

  @override
  String get mealPlanWithPantry => 'Planear com o que tenho';

  @override
  String get mealPantrySelectTitle => 'Selecionar ingredientes da despensa';

  @override
  String get mealPantrySelectHint => 'Escolha ingredientes que tem em casa';

  @override
  String mealPantrySelected(int count) {
    return '$count selecionados';
  }

  @override
  String get mealPantryApply => 'Aplicar e gerar';

  @override
  String get mealTasteProfileBoost => 'Perfil de gosto aplicado';

  @override
  String get mealPlanUndoMessage => 'Plano regenerado com sucesso';

  @override
  String get mealPlanUndoAction => 'Desfazer';

  @override
  String get mealActiveTime => 'ativo';

  @override
  String get mealPassiveTime => 'forno/espera';

  @override
  String get mealOptimizeMacros => 'Otimizar macros';

  @override
  String mealSwapSuggestion(String current, String suggested) {
    return 'Trocar $current por $suggested';
  }

  @override
  String mealSwapReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get mealApplySwap => 'Aplicar';

  @override
  String get mealSwapSameType => 'Mesmo tipo';

  @override
  String get mealSwapAllTypes => 'Todos os tipos';

  @override
  String get pantryManagerTitle => 'Despensa';

  @override
  String get pantryManagerSave => 'Guardar';

  @override
  String get pantryLowStock => 'Stock baixo';

  @override
  String get pantryDepleted => 'Esgotado';

  @override
  String get pantryRestock => 'Repor';

  @override
  String get pantryQuantity => 'Quantidade';

  @override
  String get nutritionDashboardTitle => 'NutriÃ§Ã£o Semanal';

  @override
  String get nutritionCalories => 'Calorias';

  @override
  String get nutritionProtein => 'ProteÃ­na';

  @override
  String get nutritionCarbs => 'Hidratos';

  @override
  String get nutritionFat => 'Gordura';

  @override
  String get nutritionFiber => 'Fibra';

  @override
  String get nutritionTopProteins => 'Top proteÃ­nas';

  @override
  String get nutritionDailyAvg => 'MÃ©dia diÃ¡ria';

  @override
  String get mealWasteEstimate => 'DesperdÃ­cio estimado';

  @override
  String mealWasteExcess(String qty, String unit) {
    return '$qty $unit em excesso';
  }

  @override
  String mealWasteSuggestion(String ingredient) {
    return 'Considere duplicar esta receita para usar $ingredient';
  }

  @override
  String mealWasteCost(String cost) {
    return '~$cost em desperdÃ­cio';
  }
}
