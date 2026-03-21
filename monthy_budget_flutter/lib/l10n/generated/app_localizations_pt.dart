// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get navBudget => 'Orçamento';

  @override
  String get navGrocery => 'Supermercado';

  @override
  String get navList => 'Lista';

  @override
  String get navCoach => 'Coach';

  @override
  String get navMeals => 'Refeições';

  @override
  String get navBudgetTooltip => 'Resumo do orçamento mensal';

  @override
  String get navGroceryTooltip => 'Catálogo de produtos';

  @override
  String get navListTooltip => 'Lista de compras';

  @override
  String get navCoachTooltip => 'Coach financeiro com IA';

  @override
  String get navMealsTooltip => 'Planeador de refeições';

  @override
  String get appTitle => 'Orçamento Mensal';

  @override
  String get loading => 'A carregar...';

  @override
  String get loadingApp => 'A carregar a aplicação';

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
  String get enumSubsidyNone => 'Sem duodécimos';

  @override
  String get enumSubsidyFull => 'Com duodécimos';

  @override
  String get enumSubsidyHalf => '50% duodécimos';

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
  String get enumCatTelecomunicacoes => 'Telecomunicações';

  @override
  String get enumCatEnergia => 'Energia';

  @override
  String get enumCatAgua => 'Ãgua';

  @override
  String get enumCatAlimentacao => 'Alimentação';

  @override
  String get enumCatEducacao => 'Educação';

  @override
  String get enumCatHabitacao => 'Habitação';

  @override
  String get enumCatTransportes => 'Transportes';

  @override
  String get enumCatSaude => 'Saúde';

  @override
  String get enumCatLazer => 'Lazer';

  @override
  String get enumCatOutros => 'Outros';

  @override
  String get enumChartExpensesPie => 'Despesas por Categoria';

  @override
  String get enumChartIncomeVsExpenses => 'Rendimento vs Despesas';

  @override
  String get enumChartNetIncome => 'Rendimento Líquido';

  @override
  String get enumChartDeductions => 'Descontos (IRS + SS)';

  @override
  String get enumChartSavingsRate => 'Taxa de Poupança';

  @override
  String get enumMealBreakfast => 'Pequeno-almoço';

  @override
  String get enumMealLunch => 'Almoço';

  @override
  String get enumMealSnack => 'Lanche';

  @override
  String get enumMealDinner => 'Jantar';

  @override
  String get enumObjMinimizeCost => 'Minimizar custo';

  @override
  String get enumObjBalancedHealth => 'Equilíbrio custo/saúde';

  @override
  String get enumObjHighProtein => 'Alta proteína';

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
  String get enumEquipPressureCooker => 'Panela de pressão';

  @override
  String get enumEquipMicrowave => 'Micro-ondas';

  @override
  String get enumEquipBimby => 'Bimby / Thermomix';

  @override
  String get enumSodiumNoRestriction => 'Sem restrição';

  @override
  String get enumSodiumReduced => 'Sódio reduzido';

  @override
  String get enumSodiumLow => 'Baixo sódio';

  @override
  String get enumAge0to3 => '0â€“3 anos';

  @override
  String get enumAge4to10 => '4â€“10 anos';

  @override
  String get enumAgeTeen => 'Adolescente';

  @override
  String get enumAgeAdult => 'Adulto';

  @override
  String get enumAgeSenior => 'Sénior (65+)';

  @override
  String get enumActivitySedentary => 'Sedentário';

  @override
  String get enumActivityModerate => 'Moderado';

  @override
  String get enumActivityActive => 'Ativo';

  @override
  String get enumActivityVeryActive => 'Muito ativo';

  @override
  String get enumMedDiabetes => 'Diabetes';

  @override
  String get enumMedHypertension => 'Hipertensão';

  @override
  String get enumMedHighCholesterol => 'Colesterol alto';

  @override
  String get enumMedGout => 'Gota';

  @override
  String get enumMedIbs => 'Síndrome do intestino irritável';

  @override
  String get stressExcellent => 'Excelente';

  @override
  String get stressGood => 'Bom';

  @override
  String get stressWarning => 'Atenção';

  @override
  String get stressCritical => 'Crítico';

  @override
  String get stressFactorSavings => 'Taxa de poupança';

  @override
  String get stressFactorSafety => 'Margem de segurança';

  @override
  String get stressFactorFood => 'Orçamento alimentação';

  @override
  String get stressFactorStability => 'Estabilidade despesas';

  @override
  String get stressStable => 'Estável';

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
    return 'Alimentação excedeu o orçamento em $percent% â€” considere rever porções ou frequência de compras.';
  }

  @override
  String monthReviewExpensesExceeded(String amount) {
    return 'Despesas reais superaram o planeado em $amountâ‚¬ â€” ajustar valores nas definições?';
  }

  @override
  String monthReviewSavedMore(String amount) {
    return 'Poupou $amountâ‚¬ mais do que previsto â€” pode reforçar fundo de emergência.';
  }

  @override
  String get monthReviewOnTrack =>
      'Despesas dentro do previsto. Bom controlo orçamental.';

  @override
  String get dashboardTitle => 'Orçamento Mensal';

  @override
  String get dashboardViewFullReport => 'Ver Relatório Completo';

  @override
  String get dashboardStressIndex => 'Ãndice de Tranquilidade';

  @override
  String get dashboardTension => 'Tensão';

  @override
  String get dashboardLiquidity => 'Liquidez';

  @override
  String get dashboardFinalPosition => 'Posição Final';

  @override
  String get dashboardMonth => 'Mês';

  @override
  String get dashboardGross => 'Bruto';

  @override
  String get dashboardNet => 'Líquido';

  @override
  String get dashboardExpenses => 'Despesas';

  @override
  String get dashboardSavingsRate => 'Taxa Poupança';

  @override
  String get dashboardViewTrends => 'Ver evolução';

  @override
  String get dashboardViewProjection => 'Ver projeção';

  @override
  String get dashboardFinancialSummary => 'RESUMO FINANCEIRO';

  @override
  String get dashboardOpenSettings => 'Abrir definições';

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
  String get dashboardOpenSettingsButton => 'Abrir Definições';

  @override
  String get dashboardGrossIncome => 'Rendimento Bruto';

  @override
  String get dashboardNetIncome => 'Rendimento Líquido';

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
  String get dashboardBudgeted => 'Orçado';

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
  String get dashboardGrossWithSubsidy => 'Bruto c/ duodéc.';

  @override
  String dashboardIrsRate(String rate) {
    return 'IRS ($rate)';
  }

  @override
  String get dashboardSsRate => 'SS (11%)';

  @override
  String get dashboardMealAllowance => 'Sub. Alimentação';

  @override
  String get dashboardExemptIncome => 'Rend. Isento';

  @override
  String get dashboardDetails => 'Detalhes';

  @override
  String dashboardVsLastMonth(String delta) {
    return '$delta vs mês passado';
  }

  @override
  String get dashboardPaceWarning => 'A gastar mais rápido que o previsto';

  @override
  String get dashboardPaceCritical =>
      'Risco de ultrapassar orçamento alimentar';

  @override
  String get dashboardPace => 'Ritmo';

  @override
  String get dashboardProjection => 'Projeção';

  @override
  String dashboardPaceValue(String actual, String expected) {
    return '$actualâ‚¬/dia vs $expectedâ‚¬/dia';
  }

  @override
  String get dashboardSummaryLabel => 'â€” RESUMO';

  @override
  String get dashboardViewMonthSummary => 'Ver resumo do mês';

  @override
  String get coachTitle => 'Coach Financeiro';

  @override
  String get coachSubtitle => 'IA · GPT-4o mini';

  @override
  String get coachApiKeyRequired =>
      'Adiciona a tua OpenAI API key nas Definições para usar esta funcionalidade.';

  @override
  String get coachAnalysisTitle => 'Análise financeira em 3 partes';

  @override
  String get coachAnalysisDescription =>
      'Posicionamento geral · Factores críticos do Ãndice de Tranquilidade · Oportunidade imediata. Baseado nos teus dados reais de orçamento, despesas e histórico de compras.';

  @override
  String get coachConfigureApiKey => 'Configurar API key nas Definições';

  @override
  String get coachApiKeyConfigured => 'API key configurada';

  @override
  String get coachAnalyzeButton => 'Analisar o meu orçamento';

  @override
  String get coachAnalyzing => 'A analisar...';

  @override
  String get coachCustomAnalysis => 'Análise personalizada';

  @override
  String get coachNewAnalysis => 'Gerar nova análise';

  @override
  String get coachHistory => 'HISTÃ“RICO';

  @override
  String get coachClearAll => 'Limpar tudo';

  @override
  String get coachClearTitle => 'Limpar histórico';

  @override
  String get coachClearContent =>
      'Tens a certeza que queres apagar todas as análises guardadas?';

  @override
  String get coachDeleteLabel => 'Eliminar análise';

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
    return '$unit · preço médio';
  }

  @override
  String get groceryAvailabilityTitle => 'Disponibilidade dos dados';

  @override
  String groceryAvailabilityCountry(String countryCode) {
    return 'Mercado: $countryCode';
  }

  @override
  String groceryAvailabilitySummary(int fresh, int partial, int failed) {
    return '$fresh frescas · $partial parciais · $failed indisponíveis';
  }

  @override
  String get groceryAvailabilityWarning =>
      'Algumas lojas têm dados parciais ou desatualizados. As comparações podem estar incompletas.';

  @override
  String get groceryEmptyStateTitle => 'Sem dados de supermercado disponíveis';

  @override
  String get groceryEmptyStateMessage =>
      'Tenta novamente mais tarde ou muda de mercado nas definições.';

  @override
  String get shoppingTitle => 'Lista de Compras';

  @override
  String get shoppingEmpty => 'Lista vazia';

  @override
  String get shoppingEmptyMessage =>
      'Adiciona produtos a partir do\necrã Supermercado.';

  @override
  String shoppingItemsRemaining(int count, String total) {
    return '$count por comprar · $total';
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
  String get shoppingHistoryTooltip => 'Histórico de compras';

  @override
  String get shoppingHistoryTitle => 'Histórico de Compras';

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
  String get authSwitchToLogin => 'Já tenho conta';

  @override
  String get authRegistrationSuccess =>
      'Conta criada! Verifique o seu email para confirmar a conta antes de iniciar sessão.';

  @override
  String get authErrorNetwork =>
      'Não foi possível ligar ao servidor. Verifique a sua ligação Ã  internet e tente novamente.';

  @override
  String get authErrorInvalidCredentials =>
      'Email ou palavra-passe inválidos. Tente novamente.';

  @override
  String get authErrorEmailNotConfirmed =>
      'Verifique o seu email antes de iniciar sessão.';

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
  String get householdJoinWithCode => 'Entrar com código';

  @override
  String get householdNameLabel => 'Nome do agregado';

  @override
  String get householdNameHint => 'ex: Família Silva';

  @override
  String get householdCodeLabel => 'Código de convite';

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
  String get chartDeductions => 'Descontos (IRS + Segurança Social)';

  @override
  String get chartGrossVsNet => 'Rendimento Bruto vs Líquido';

  @override
  String get chartSavingsRate => 'Taxa de Poupança';

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
  String get chartNet => 'Líquido';

  @override
  String get chartNetSalary => 'Sal. Líquido';

  @override
  String get chartIRS => 'IRS';

  @override
  String get chartSocialSecurity => 'Seg. Social';

  @override
  String get chartSavings => 'poupança';

  @override
  String projectionTitle(String month, String year) {
    return 'Projeção â€” $month $year';
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
    return 'Gasto diário estimado: $amount/dia';
  }

  @override
  String get projectionEndOfMonth => 'Projeção fim de mês';

  @override
  String get projectionRemaining => 'Restante projetado';

  @override
  String get projectionStressImpact => 'Impacto no Ãndice';

  @override
  String get projectionExpenses => 'DESPESAS';

  @override
  String get projectionSimulation => 'Simulação â€” não guardado';

  @override
  String get projectionReduceAll => 'Reduzir todas em ';

  @override
  String get projectionSimLiquidity => 'Liquidez simulada';

  @override
  String get projectionDelta => 'Delta';

  @override
  String get projectionSimSavingsRate => 'Taxa poupança simulada';

  @override
  String get projectionSimIndex => 'Ãndice simulado';

  @override
  String get trendTitle => 'Evolução';

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
  String get trendCatFood => 'Alimentação';

  @override
  String get trendCatEducation => 'Educação';

  @override
  String get trendCatHousing => 'Habitação';

  @override
  String get trendCatTransport => 'Transportes';

  @override
  String get trendCatHealth => 'Saúde';

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
  String get monthReviewDifference => 'Diferença';

  @override
  String get monthReviewFood => 'Alimentação';

  @override
  String monthReviewFoodValue(String actual, String budget) {
    return '$actual de $budget';
  }

  @override
  String get monthReviewTopDeviations => 'MAIORES DESVIOS';

  @override
  String get monthReviewSuggestions => 'SUGESTÃ•ES';

  @override
  String get monthReviewAiAnalysis => 'Análise AI detalhada';

  @override
  String get mealPlannerTitle => 'Planeador de Refeições';

  @override
  String get mealBudgetLabel => 'Orçamento alimentação';

  @override
  String get mealPeopleLabel => 'Pessoas no agregado';

  @override
  String get mealGeneratePlan => 'Gerar Plano Mensal';

  @override
  String get mealGenerating => 'A gerar...';

  @override
  String get mealRegenerateTitle => 'Regenerar plano?';

  @override
  String get mealRegenerateContent => 'O plano atual será substituído.';

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
  String get mealPreparation => 'Preparação';

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
  String get mealCatProteins => 'Proteínas';

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
  String get wizardStepMeals => 'Refeições';

  @override
  String get wizardStepObjective => 'Objetivo';

  @override
  String get wizardStepRestrictions => 'Restrições';

  @override
  String get wizardStepKitchen => 'Cozinha';

  @override
  String get wizardStepStrategy => 'Estratégia';

  @override
  String get wizardMealsQuestion =>
      'Quais refeições queres incluir no plano diário?';

  @override
  String wizardBudgetWeight(String weight) {
    return '$weight do orçamento';
  }

  @override
  String get wizardObjectiveQuestion =>
      'Qual é o objetivo principal do teu plano alimentar?';

  @override
  String wizardSelected(String label) {
    return '$label, selecionado';
  }

  @override
  String get wizardDietaryRestrictions => 'RESTRIÃ‡Ã•ES DIETÃ‰TICAS';

  @override
  String get wizardGlutenFree => 'Sem glúten';

  @override
  String get wizardLactoseFree => 'Sem lactose';

  @override
  String get wizardNutFree => 'Sem frutos secos';

  @override
  String get wizardShellfishFree => 'Sem marisco';

  @override
  String get wizardDislikedIngredients => 'INGREDIENTES QUE NÃƒO GOSTAS';

  @override
  String get wizardDislikedHint => 'ex: atum, brócolos';

  @override
  String get wizardMaxPrepTime => 'TEMPO MÃXIMO POR REFEIÃ‡ÃƒO';

  @override
  String get wizardMaxComplexity => 'COMPLEXIDADE MÃXIMA';

  @override
  String get wizardComplexityEasy => 'Fácil';

  @override
  String get wizardComplexityMedium => 'Médio';

  @override
  String get wizardComplexityAdvanced => 'Avançado';

  @override
  String get wizardEquipment => 'EQUIPAMENTO DISPONÃVEL';

  @override
  String get wizardBatchCooking => 'Batch cooking';

  @override
  String get wizardBatchCookingDesc => 'Cozinhar para vários dias de uma vez';

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
      'Jantar de ontem = almoço de hoje (custo 0)';

  @override
  String get wizardMaxNewIngredients =>
      'MÃXIMO DE INGREDIENTES NOVOS POR SEMANA';

  @override
  String get wizardNoLimit => 'Sem limite';

  @override
  String get wizardMinimizeWaste => 'Minimizar desperdício';

  @override
  String get wizardMinimizeWasteDesc =>
      'Prefere receitas que reutilizam ingredientes já usados';

  @override
  String get wizardSettingsInfo =>
      'Podes alterar as definições do planeador em qualquer altura em Definições â†’ Refeições.';

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
  String get settingsTitle => 'Definições';

  @override
  String get settingsPersonal => 'Dados Pessoais';

  @override
  String get settingsSalaries => 'Salários';

  @override
  String get settingsExpenses => 'Orçamento e Pagamentos Recorrentes';

  @override
  String get settingsCoachAi => 'Coach IA';

  @override
  String get settingsDashboard => 'Dashboard';

  @override
  String get settingsMeals => 'Refeições';

  @override
  String get settingsRegion => 'Região e Idioma';

  @override
  String get settingsCountry => 'País';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsMaritalStatus => 'Estado civil';

  @override
  String get settingsDependents => 'Dependentes';

  @override
  String get settingsDisability => 'Deficiente';

  @override
  String get settingsGrossSalary => 'Salário bruto';

  @override
  String get settingsTitulares => 'Titulares';

  @override
  String get settingsSubsidyMode => 'Duodécimos';

  @override
  String get settingsMealAllowance => 'Subsídio de alimentação';

  @override
  String get settingsMealAllowancePerDay => 'Valor/dia';

  @override
  String get settingsWorkingDays => 'Dias úteis/mês';

  @override
  String get settingsOtherExemptIncome => 'Outros rendimentos isentos';

  @override
  String get settingsAddSalary => 'Adicionar salário';

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
  String get settingsInviteCode => 'Código de convite';

  @override
  String get settingsCopyCode => 'Copiar';

  @override
  String get settingsCodeCopied => 'Código copiado!';

  @override
  String get settingsAdminOnly =>
      'Apenas o administrador pode editar as definições.';

  @override
  String get settingsShowSummaryCards => 'Mostrar cartões resumo';

  @override
  String get settingsEnabledCharts => 'Gráficos ativos';

  @override
  String get settingsLogout => 'Terminar sessão';

  @override
  String get settingsLogoutConfirmTitle => 'Terminar sessão';

  @override
  String get settingsLogoutConfirmContent => 'Tens a certeza que queres sair?';

  @override
  String get settingsLogoutConfirmButton => 'Sair';

  @override
  String get settingsSalariesSection => 'Vencimentos';

  @override
  String get settingsExpensesMonthly => 'Orçamento e Pagamentos Recorrentes';

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
    return 'Segurança Social: $rate';
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
      'Estas definições são guardadas neste dispositivo.';

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
  String get settingsDashSummaryCards => 'Cartões de resumo';

  @override
  String get settingsDashSalaryBreakdown => 'Detalhe por vencimento';

  @override
  String get settingsDashFood => 'Alimentação';

  @override
  String get settingsDashPurchaseHistory => 'Histórico de compras';

  @override
  String get settingsDashExpensesBreakdown => 'Breakdown despesas';

  @override
  String get settingsDashMonthReview => 'Revisão do mês';

  @override
  String get settingsDashCharts => 'Gráficos';

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
      'Os produtos favoritos influenciam o plano de refeições â€” receitas com esses ingredientes ficam em prioridade.';

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
  String get settingsUseAutoValue => 'Usar valor automático';

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
  String get settingsPortions => 'porções';

  @override
  String settingsTotalEquivalent(String total) {
    return 'Equivalente total: $total porções';
  }

  @override
  String get settingsAddMember => 'Adicionar membro';

  @override
  String get settingsPreferSeasonal => 'Preferir receitas sazonais';

  @override
  String get settingsPreferSeasonalDesc => 'Prioriza receitas da época atual';

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
  String get settingsDailyProtein => 'Proteína diária';

  @override
  String get settingsDailyFiber => 'Fibra diária';

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
  String get settingsNoMinimum => 'sem mínimo';

  @override
  String settingsLegumePerWeek(String count) {
    return 'Leguminosas por semana: $count';
  }

  @override
  String settingsRedMeatPerWeek(String count) {
    return 'Carne vermelha máx/semana: $count';
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
  String get settingsMinimizeWaste => 'Minimizar desperdício';

  @override
  String get settingsPrioritizeLowCost => 'Priorizar custo baixo';

  @override
  String get settingsPrioritizeLowCostDesc =>
      'Preferir receitas mais económicas';

  @override
  String settingsNewIngredientsPerWeek(int count) {
    return 'INGREDIENTES NOVOS POR SEMANA ($count)';
  }

  @override
  String get settingsLunchboxLunches => 'Almoços de marmita';

  @override
  String get settingsLunchboxLunchesDesc =>
      'Apenas receitas transportáveis ao almoço';

  @override
  String get settingsPantry => 'DESPENSA (SEMPRE EM STOCK)';

  @override
  String get settingsResetWizard => 'Repor Wizard';

  @override
  String get settingsApiKeyInfo =>
      'A key é guardada localmente no dispositivo e nunca é partilhada. Usa o modelo GPT-4o mini (~â‚¬0,00008 por análise).';

  @override
  String get settingsInviteCodeLabel => 'CÃ“DIGO DE CONVITE';

  @override
  String get settingsGenerateInvite => 'Gerar código de convite';

  @override
  String get settingsShareWithMembers => 'Partilha com membros do agregado';

  @override
  String get settingsNewCode => 'Novo código';

  @override
  String get settingsCodeValidInfo =>
      'O código é válido por 7 dias. Partilha-o com quem queres adicionar ao agregado.';

  @override
  String get settingsName => 'Nome';

  @override
  String get settingsAgeGroup => 'Faixa etária';

  @override
  String get settingsActivityLevel => 'Nível de atividade';

  @override
  String settingsSalaryN(int n) {
    return 'Vencimento $n';
  }

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryES => 'Espanha';

  @override
  String get countryFR => 'França';

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
  String get taxIncomeTax => 'Imposto sobre rendimento';

  @override
  String get taxSocialContribution => 'Contribuição social';

  @override
  String get taxIRS => 'IRS';

  @override
  String get taxSS => 'Segurança Social';

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
      'Ã‰s um analista financeiro pessoal para utilizadores portugueses. Responde sempre em português europeu. Sê directo e analítico â€” usa sempre números concretos do contexto fornecido. Estrutura a resposta exactamente nas 3 partes pedidas. Não introduzas dados, benchmarks ou referências externas que não foram fornecidos.';

  @override
  String get aiCoachInvalidApiKey =>
      'API key inválida. Verifica nas Definições.';

  @override
  String get aiCoachMidMonthSystem =>
      'Ã‰s um consultor de orçamento doméstico português. Responde sempre em português europeu. Sê prático e directo.';

  @override
  String get aiMealPlannerSystem =>
      'Ã‰s um chef português. Responde sempre em português europeu. Responde APENAS com JSON válido, sem texto extra.';

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
  String get monthFullMar => 'Março';

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
  String get setupWizardWelcomeTitle => 'Bem-vindo ao seu orçamento';

  @override
  String get setupWizardWelcomeSubtitle =>
      'Vamos configurar o essencial para que o seu painel fique pronto a usar.';

  @override
  String get setupWizardBullet1 => 'Calcular o seu salário líquido';

  @override
  String get setupWizardBullet2 => 'Organizar as suas despesas';

  @override
  String get setupWizardBullet3 => 'Ver quanto sobra cada mês';

  @override
  String get setupWizardReassurance =>
      'Pode alterar tudo mais tarde nas definições.';

  @override
  String get setupWizardStart => 'Começar';

  @override
  String get setupWizardSkipAll => 'Saltar configuração';

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
  String get setupWizardLangSystem => 'Predefinição do sistema';

  @override
  String get setupWizardCountryPT => 'Portugal';

  @override
  String get setupWizardCountryES => 'Espanha';

  @override
  String get setupWizardCountryFR => 'França';

  @override
  String get setupWizardCountryUK => 'Reino Unido';

  @override
  String get setupWizardPersonalTitle => 'Informação pessoal';

  @override
  String get setupWizardPersonalSubtitle =>
      'Usamos isto para calcular os seus impostos com mais precisão.';

  @override
  String get setupWizardPrivacyNote =>
      'Os seus dados ficam na sua conta e nunca são partilhados.';

  @override
  String get setupWizardSingle => 'Solteiro(a)';

  @override
  String get setupWizardMarried => 'Casado(a)';

  @override
  String get setupWizardDependents => 'Dependentes';

  @override
  String get setupWizardTitulares => 'Titulares';

  @override
  String get setupWizardSalaryTitle => 'Qual é o seu salário?';

  @override
  String get setupWizardSalarySubtitle =>
      'Introduza o valor bruto mensal. Calculamos o líquido automaticamente.';

  @override
  String get setupWizardSalaryGross => 'Salário bruto mensal';

  @override
  String setupWizardNetEstimate(String amount) {
    return 'Líquido estimado: $amount';
  }

  @override
  String get setupWizardSalaryMoreLater =>
      'Pode adicionar mais fontes de rendimento mais tarde.';

  @override
  String get setupWizardSalaryRequired => 'Por favor insira o seu salário';

  @override
  String get setupWizardSalaryPositive =>
      'O salário deve ser um número positivo';

  @override
  String get setupWizardSalarySkip => 'Saltar este passo';

  @override
  String get setupWizardExpensesTitle => 'As suas despesas mensais';

  @override
  String get setupWizardExpensesSubtitle =>
      'Valores sugeridos para o seu país. Ajuste conforme necessário.';

  @override
  String get setupWizardExpensesMoreLater =>
      'Pode adicionar mais categorias mais tarde.';

  @override
  String setupWizardNetLabel(String amount) {
    return 'Líquido: $amount';
  }

  @override
  String setupWizardTotalExpenses(String amount) {
    return 'Despesas: $amount';
  }

  @override
  String setupWizardAvailableLabel(String amount) {
    return 'Disponível: $amount';
  }

  @override
  String get setupWizardFinish => 'Concluir';

  @override
  String get setupWizardCompleteTitle => 'Tudo pronto!';

  @override
  String get setupWizardCompleteReassurance =>
      'O seu orçamento está configurado. Pode ajustar tudo nas definições a qualquer momento.';

  @override
  String get setupWizardGoToDashboard => 'Ver o meu orçamento';

  @override
  String get setupWizardConfigureSalaryHint =>
      'Configure o seu salário nas definições para ver o cálculo completo.';

  @override
  String get setupWizardExpRent => 'Renda / Prestação';

  @override
  String get setupWizardExpGroceries => 'Alimentação';

  @override
  String get setupWizardExpTransport => 'Transportes';

  @override
  String get setupWizardExpUtilities => 'Utilidades (luz, água, gás)';

  @override
  String get setupWizardExpTelecom => 'Telecomunicações';

  @override
  String get setupWizardExpHealth => 'Saúde';

  @override
  String get setupWizardExpLeisure => 'Lazer';

  @override
  String get expenseTrackerTitle => 'ORÃ‡AMENTO VS REAL';

  @override
  String get expenseTrackerBudgeted => 'Orçamentado';

  @override
  String get expenseTrackerActual => 'Real';

  @override
  String get expenseTrackerRemaining => 'Restante';

  @override
  String get expenseTrackerOver => 'Acima do orçamento';

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
      'Sem despesas este mês.\nToca + para adicionar a primeira.';

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
  String get addExpenseDescription => 'Descrição (opcional)';

  @override
  String get addExpenseCustomCategory => 'Categoria personalizada';

  @override
  String get addExpenseInvalidAmount => 'Introduza um valor válido';

  @override
  String get addExpenseTooltip => 'Registar despesa';

  @override
  String get addExpenseItem => 'Despesa';

  @override
  String get addExpenseOthers => 'Outros';

  @override
  String get settingsDashBudgetVsActual => 'Orçamento vs Real';

  @override
  String get settingsAppearance => 'Aparência';

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
  String get recurringExpenseDescription => 'Descrição (opcional)';

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
      'Pagamentos recorrentes gerados para este mês';

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
    return '$count pagamentos · $amount/mês';
  }

  @override
  String billsExceedBudget(String amount) {
    return 'Contas ($amount) excedem orçamento';
  }

  @override
  String get billsAddBill => 'Adicionar Pagamento Recorrente';

  @override
  String get billsBudgetSettings => 'Configuração do Orçamento';

  @override
  String get billsRecurringBills => 'Pagamentos Recorrentes';

  @override
  String get billsDescription => 'Descrição';

  @override
  String get billsAmount => 'Montante';

  @override
  String get billsDueDay => 'Dia de vencimento';

  @override
  String get billsActive => 'Ativa';

  @override
  String get expenseTrends => 'Tendências de Despesas';

  @override
  String get expenseTrendsViewTrends => 'Ver Tendências';

  @override
  String get expenseTrends3Months => '3M';

  @override
  String get expenseTrends6Months => '6M';

  @override
  String get expenseTrends12Months => '12M';

  @override
  String get expenseTrendsBudgeted => 'Orçamentado';

  @override
  String get expenseTrendsActual => 'Real';

  @override
  String get expenseTrendsByCategory => 'Por Categoria';

  @override
  String get expenseTrendsNoData =>
      'Sem dados suficientes para mostrar tendências.';

  @override
  String get expenseTrendsTotal => 'Total';

  @override
  String get expenseTrendsAverage => 'Média';

  @override
  String get expenseTrendsOverview => 'Visão Geral';

  @override
  String get expenseTrendsMonthly => 'Mensal';

  @override
  String get savingsGoals => 'Objetivos de Poupança';

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
    return '$percent% alcançado';
  }

  @override
  String savingsGoalRemaining(String amount) {
    return 'Faltam $amount';
  }

  @override
  String get savingsGoalCompleted => 'Objetivo alcançado!';

  @override
  String get savingsGoalEmpty =>
      'Sem objetivos de poupança.\nCrie um para acompanhar o progresso.';

  @override
  String get savingsGoalDeleteConfirm => 'Eliminar este objetivo?';

  @override
  String get savingsGoalContribute => 'Contribuir';

  @override
  String get savingsGoalContributionAmount => 'Valor da contribuição';

  @override
  String get savingsGoalContributionNote => 'Nota (opcional)';

  @override
  String get savingsGoalContributionDate => 'Data';

  @override
  String get savingsGoalContributionHistory => 'Histórico de Contribuições';

  @override
  String get savingsGoalSeeAll => 'Ver todos';

  @override
  String savingsGoalSurplusSuggestion(String amount) {
    return 'Tiveste $amount de excedente no mês passado â€” queres alocar a um objetivo?';
  }

  @override
  String get savingsGoalAllocate => 'Alocar';

  @override
  String get savingsGoalSaved => 'Objetivo guardado';

  @override
  String get savingsGoalContributionSaved => 'Contribuição registada';

  @override
  String get settingsDashSavingsGoals => 'Objetivos de Poupança';

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
  String get mealCostReconciliation => 'Custos de Refeições';

  @override
  String get mealCostEstimated => 'Estimado';

  @override
  String get mealCostActual => 'Real';

  @override
  String mealCostWeek(String number) {
    return 'Semana $number';
  }

  @override
  String get mealCostTotal => 'Total do Mês';

  @override
  String get mealCostSavings => 'Poupança';

  @override
  String get mealCostOverrun => 'Excesso';

  @override
  String get mealCostNoData => 'Sem dados de compras para refeições.';

  @override
  String get mealCostViewCosts => 'Custos';

  @override
  String get mealCostIsMealPurchase => 'Compra para refeições';

  @override
  String get mealCostVsBudget => 'vs orçamento';

  @override
  String get mealCostOnTrack => 'Dentro do orçamento';

  @override
  String get mealCostOver => 'Acima do orçamento';

  @override
  String get mealCostUnder => 'Abaixo do orçamento';

  @override
  String get mealVariation => 'Variação';

  @override
  String get mealPairing => 'Acompanhamento';

  @override
  String get mealStorage => 'Conservação';

  @override
  String get mealLeftover => 'Sobras';

  @override
  String get mealLeftoverIdea => 'Ideia de reaproveitamento';

  @override
  String get mealWeeklySummary => 'Nutrição Semanal';

  @override
  String get mealBatchPrepGuide => 'Cozinha em Lote';

  @override
  String get mealViewPrepGuide => 'Preparação';

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
  String get mealFeedbackDislike => 'Não gostei';

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
  String get notifications => 'Notificações';

  @override
  String get notificationSettings => 'Definições de Notificações';

  @override
  String get notificationPreferredTime => 'Hora preferida';

  @override
  String get notificationPreferredTimeDesc =>
      'Notificações agendadas usarão esta hora (exceto lembretes personalizados)';

  @override
  String get notificationBillReminders => 'Lembretes de pagamentos';

  @override
  String get notificationBillReminderDays => 'Dias antes do vencimento';

  @override
  String get notificationBudgetAlerts => 'Alertas de orçamento';

  @override
  String notificationBudgetThreshold(String percent) {
    return 'Limite de alerta ($percent%)';
  }

  @override
  String get notificationMealPlanReminder => 'Lembrete de plano de refeições';

  @override
  String get notificationMealPlanReminderDesc =>
      'Notifica se não há plano para o mês atual';

  @override
  String get notificationCustomReminders => 'Lembretes Personalizados';

  @override
  String get notificationAddCustom => 'Adicionar Lembrete';

  @override
  String get notificationCustomTitle => 'Título';

  @override
  String get notificationCustomBody => 'Mensagem';

  @override
  String get notificationCustomTime => 'Hora';

  @override
  String get notificationCustomRepeat => 'Repetir';

  @override
  String get notificationCustomRepeatDaily => 'Diário';

  @override
  String get notificationCustomRepeatWeekly => 'Semanal';

  @override
  String get notificationCustomRepeatMonthly => 'Mensal';

  @override
  String get notificationCustomRepeatNone => 'Não repetir';

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
  String get notificationBudgetTitle => 'Alerta de orçamento';

  @override
  String notificationBudgetBody(String percent) {
    return 'Já gastaste $percent% do orçamento mensal';
  }

  @override
  String get notificationMealPlanTitle => 'Plano de refeições';

  @override
  String get notificationMealPlanBody =>
      'Ainda não geraste o plano de refeições deste mês';

  @override
  String get notificationPermissionRequired =>
      'Permissão de notificações necessária';

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
  String get paletteTeal => 'Azul-petróleo';

  @override
  String get paletteSunset => 'PÃ´r do sol';

  @override
  String get exportTooltip => 'Exportar';

  @override
  String get exportTitle => 'Exportar mês';

  @override
  String get exportPdf => 'Relatório PDF';

  @override
  String get exportPdfDesc => 'Relatório formatado com orçamento vs real';

  @override
  String get exportCsv => 'Dados CSV';

  @override
  String get exportCsvDesc => 'Dados brutos para folha de cálculo';

  @override
  String get exportReportTitle => 'Relatório Mensal de Despesas';

  @override
  String get exportBudgetVsActual => 'Orçamento vs Real';

  @override
  String get exportExpenseDetail => 'Detalhe de Despesas';

  @override
  String get searchExpenses => 'Pesquisar';

  @override
  String get searchExpensesHint => 'Pesquisar por descrição...';

  @override
  String get searchDateRange => 'Período';

  @override
  String get searchNoResults => 'Nenhuma despesa encontrada';

  @override
  String searchResultCount(int count) {
    return '$count resultados';
  }

  @override
  String get expenseFixed => 'Fixo';

  @override
  String get expenseVariable => 'Variável';

  @override
  String monthlyBudgetHint(String month) {
    return 'Orçamento para $month';
  }

  @override
  String unsetBudgetsWarning(int count) {
    return '$count orçamentos variáveis por definir';
  }

  @override
  String get unsetBudgetsCta => 'Definir nas definições';

  @override
  String paceProjected(String amount) {
    return 'Projeção: $amount';
  }

  @override
  String get onbSkip => 'Saltar';

  @override
  String get onbNext => 'Seguinte';

  @override
  String get onbGetStarted => 'Começar';

  @override
  String get onbSlide0Title => 'O seu orçamento, num relance';

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
      'Obtenha uma análise em 3 partes baseada no seu orçamento real â€” não conselhos genéricos.';

  @override
  String get onbSlide4Title => 'Planeie refeições no orçamento';

  @override
  String get onbSlide4Body =>
      'Gere um plano mensal ajustado ao seu orçamento alimentar e agregado familiar.';

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
      'Pontuação de saúde financeira 0â€“100. Toque para ver os fatores.';

  @override
  String get onbTourDash3Title => 'Orçamento vs real';

  @override
  String get onbTourDash3Body => 'Gastos planeados vs reais por categoria.';

  @override
  String get onbTourDash4Title => 'Adicionar despesa';

  @override
  String get onbTourDash4Body =>
      'Toque + a qualquer momento para registar uma despesa.';

  @override
  String get onbTourDash5Title => 'Navegação';

  @override
  String get onbTourDash5Body =>
      '5 secções: Orçamento, Supermercado, Lista, Coach, Refeições.';

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
  String get onbTourShopping3Title => 'Histórico de compras';

  @override
  String get onbTourShopping3Body =>
      'Veja todas as sessões de compras anteriores aqui.';

  @override
  String get onbTourCoach1Title => 'Analisar o meu orçamento';

  @override
  String get onbTourCoach1Body =>
      'Toque para gerar uma análise baseada nos seus dados reais.';

  @override
  String get onbTourCoach2Title => 'Histórico de análises';

  @override
  String get onbTourCoach2Body =>
      'As análises guardadas aparecem aqui, mais recentes primeiro.';

  @override
  String get onbTourMeals1Title => 'Gerar plano';

  @override
  String get onbTourMeals1Body =>
      'Cria um mês completo de refeições dentro do orçamento alimentar.';

  @override
  String get onbTourMeals2Title => 'Vista semanal';

  @override
  String get onbTourMeals2Body =>
      'Navegue refeições por semana. Toque num dia para ver a receita.';

  @override
  String get onbTourMeals3Title => 'Adicionar Ã  lista de compras';

  @override
  String get onbTourMeals3Body =>
      'Envie os ingredientes da semana para a lista com um toque.';

  @override
  String get onbTourExpenseTracker1Title => 'Navegação mensal';

  @override
  String get onbTourExpenseTracker1Body =>
      'Alterne entre meses para ver ou adicionar despesas de qualquer período.';

  @override
  String get onbTourExpenseTracker2Title => 'Resumo do orçamento';

  @override
  String get onbTourExpenseTracker2Body =>
      'Veja o orçado vs real e o saldo restante de relance.';

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
      'Cada cartão mostra o progresso em direção ao objetivo. Toque para ver detalhes e adicionar contribuições.';

  @override
  String get onbTourSavings2Title => 'Criar objetivo';

  @override
  String get onbTourSavings2Body =>
      'Toque + para definir um novo objetivo de poupança com valor alvo e prazo opcional.';

  @override
  String get onbTourRecurring1Title => 'Despesas recorrentes';

  @override
  String get onbTourRecurring1Body =>
      'Contas fixas mensais como renda, subscrições e serviços. São incluídas automaticamente no orçamento.';

  @override
  String get onbTourRecurring2Title => 'Adicionar recorrente';

  @override
  String get onbTourRecurring2Body =>
      'Toque + para registar uma nova despesa recorrente com valor e dia de vencimento.';

  @override
  String get onbTourAssistant1Title => 'Assistente de comandos';

  @override
  String get onbTourAssistant1Body =>
      'O seu atalho para ações rápidas. Toque para adicionar despesas, mudar definições, navegar e mais â€” basta escrever o que precisa.';

  @override
  String get taxDeductionTitle => 'Deduções IRS';

  @override
  String get taxDeductionSeeDetail => 'Ver detalhe';

  @override
  String get taxDeductionEstimated => 'dedução estimada';

  @override
  String taxDeductionMaxOf(String amount) {
    return 'Máx. de $amount';
  }

  @override
  String get taxDeductionDetailTitle => 'Deduções IRS â€” Detalhe';

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
  String get taxDeductionNotDeductible => 'Não dedutível';

  @override
  String get taxDeductionDisclaimer =>
      'Estes valores são estimativas baseadas nas despesas registadas. As deduções reais dependem das faturas registadas no e-Fatura. Consulte um profissional fiscal para valores definitivos.';

  @override
  String get settingsDashTaxDeductions => 'Deduções fiscais (PT)';

  @override
  String get settingsDashUpcomingBills => 'Próximos pagamentos';

  @override
  String get settingsDashBudgetStreaks => 'Séries de orçamento';

  @override
  String get settingsDashQuickActions => 'Ações rápidas';

  @override
  String get upcomingBillsTitle => 'Próximos Pagamentos';

  @override
  String get upcomingBillsManage => 'Gerir';

  @override
  String get billDueToday => 'Hoje';

  @override
  String get billDueTomorrow => 'Amanhã';

  @override
  String billDueInDays(int days) {
    return 'Em $days dias';
  }

  @override
  String savingsProjectionReachedBy(String date) {
    return 'Atingido até $date';
  }

  @override
  String savingsProjectionNeedPerMonth(String amount) {
    return 'Precisa $amount/mês para cumprir prazo';
  }

  @override
  String get savingsProjectionOnTrack => 'No caminho certo';

  @override
  String get savingsProjectionBehind => 'Atrasado';

  @override
  String get savingsProjectionNoData =>
      'Adicione contribuições para ver projeção';

  @override
  String savingsProjectionAvgContribution(String amount) {
    return 'Média $amount/mês';
  }

  @override
  String get taxSimTitle => 'Simulador Fiscal';

  @override
  String get taxSimPresets => 'CENÃRIOS RÃPIDOS';

  @override
  String get taxSimPresetRaise => '+â‚¬200 aumento';

  @override
  String get taxSimPresetMeal => 'Cartão vs dinheiro';

  @override
  String get taxSimPresetTitular => 'Ãšnico vs conjunto';

  @override
  String get taxSimParameters => 'PARÃ‚METROS';

  @override
  String get taxSimGross => 'Salário bruto';

  @override
  String get taxSimMarital => 'Estado civil';

  @override
  String get taxSimTitulares => 'Titulares';

  @override
  String get taxSimDependentes => 'Dependentes';

  @override
  String get taxSimMealType => 'Tipo de subsídio de alimentação';

  @override
  String get taxSimMealAmount => 'Subsídio alim./dia';

  @override
  String get taxSimComparison => 'ATUAL VS SIMULADO';

  @override
  String get taxSimNetTakeHome => 'Líquido a receber';

  @override
  String get taxSimIRS => 'Retenção IRS';

  @override
  String get taxSimSS => 'Segurança social';

  @override
  String get taxSimDelta => 'Diferença mensal:';

  @override
  String get taxSimButton => 'Simulador Fiscal';

  @override
  String get streakTitle => 'Séries de Orçamento';

  @override
  String get streakBronze => 'Bronze';

  @override
  String get streakSilver => 'Prata';

  @override
  String get streakGold => 'Ouro';

  @override
  String get streakBronzeDesc => 'Liquidez positiva';

  @override
  String get streakSilverDesc => 'Dentro do orçamento';

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
  String get expenseAdjustMonthHint => 'Deixe vazio para usar o orçamento base';

  @override
  String get settingsPersonalTip =>
      'O estado civil e dependentes afetam o escalão de IRS, que determina o imposto retido no salário.';

  @override
  String get settingsSalariesTip =>
      'O salário bruto é usado para calcular o rendimento líquido após impostos e segurança social. Adicione vários salários se o agregado tiver mais que um rendimento.';

  @override
  String get settingsExpensesTip =>
      'Defina o orçamento mensal para cada categoria. Pode ajustar para meses específicos na vista de detalhe da categoria.';

  @override
  String get settingsMealHouseholdTip =>
      'Número de pessoas que fazem refeições em casa. Isto ajusta receitas e porções no plano alimentar.';

  @override
  String get settingsHouseholdTip =>
      'Convide membros da família para partilhar dados do orçamento entre dispositivos. Todos veem as mesmas despesas e orçamentos.';

  @override
  String get subscriptionTitle => 'Subscrição';

  @override
  String get subscriptionFree => 'Gratuito';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String get subscriptionFamily => 'Família';

  @override
  String get subscriptionTrialActive => 'Período de teste ativo';

  @override
  String subscriptionTrialDaysLeft(int count) {
    return '$count dias restantes';
  }

  @override
  String get subscriptionTrialExpired => 'Período de teste expirado';

  @override
  String get subscriptionUpgrade => 'Atualizar';

  @override
  String get subscriptionSeePlans => 'Ver Planos';

  @override
  String get subscriptionCurrentPlan => 'Plano Atual';

  @override
  String get subscriptionManage => 'Gerir Subscrição';

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
  String get subscriptionPerMonth => '/mês';

  @override
  String get subscriptionPerYear => '/ano';

  @override
  String get subscriptionBilledYearly => 'faturado anualmente';

  @override
  String get subscriptionStartPremium => 'Começar Premium';

  @override
  String get subscriptionStartFamily => 'Começar Família';

  @override
  String get subscriptionContinueFree => 'Continuar Gratuito';

  @override
  String get subscriptionTrialEnded => 'O seu período de teste terminou';

  @override
  String get subscriptionChoosePlan =>
      'Escolha um plano para manter todos os seus dados e funcionalidades';

  @override
  String get subscriptionUnlockPower =>
      'Desbloqueie todo o poder do seu orçamento';

  @override
  String subscriptionRequiresPaid(String feature) {
    return '$feature requer uma subscrição paga';
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
      'Sugere receitas que podem ser preparadas com antecedência para várias refeições';

  @override
  String get subtitleReuseLeftovers =>
      'Planeia refeições que reutilizam ingredientes de dias anteriores';

  @override
  String get subtitleMinimizeWaste =>
      'Prioriza o uso de todos os ingredientes comprados antes de expirarem';

  @override
  String get subtitleMealTypeInclude =>
      'Incluir esta refeição no plano semanal';

  @override
  String get subtitleShowHeroCard => 'Resumo da liquidez líquida no topo';

  @override
  String get subtitleShowStressIndex =>
      'Pontuação (0-100) que mede a pressão de despesas vs rendimento';

  @override
  String get subtitleShowMonthReview =>
      'Resumo comparativo deste mês com os anteriores';

  @override
  String get subtitleShowUpcomingBills =>
      'Despesas recorrentes nos próximos 30 dias';

  @override
  String get subtitleShowSummaryCards =>
      'Rendimento, deduções, despesas e taxa de poupança';

  @override
  String get subtitleShowBudgetVsActual =>
      'Comparação lado a lado por categoria de despesa';

  @override
  String get subtitleShowExpensesBreakdown =>
      'Gráfico circular de despesas por categoria';

  @override
  String get subtitleShowSavingsGoals =>
      'Progresso em relação aos seus objetivos de poupança';

  @override
  String get subtitleShowTaxDeductions =>
      'Deduções fiscais elegíveis estimadas este ano';

  @override
  String get subtitleShowBudgetStreaks =>
      'Quantos meses consecutivos ficou dentro do orçamento';

  @override
  String get subtitleShowQuickActions =>
      'Atalhos para adicionar despesas, navegar e mais';

  @override
  String get subtitleShowPurchaseHistory =>
      'Compras recentes da lista de compras e custos';

  @override
  String get subtitleShowCharts =>
      'Gráficos de tendência de orçamento, despesas e rendimento';

  @override
  String get subtitleChartExpensesPie =>
      'Distribuição de despesas por categoria';

  @override
  String get subtitleChartIncomeVsExpenses =>
      'Rendimento mensal comparado com despesas totais';

  @override
  String get subtitleChartDeductions =>
      'Discriminação de despesas dedutíveis nos impostos';

  @override
  String get subtitleChartNetIncome =>
      'Tendência do rendimento líquido ao longo do tempo';

  @override
  String get subtitleChartSavingsRate =>
      'Percentagem de rendimento poupado por mês';

  @override
  String get helperCountry =>
      'Determina o sistema fiscal, moeda e taxas de segurança social';

  @override
  String get helperLanguage =>
      'Substituir o idioma do sistema. \"Sistema\" segue a definição do dispositivo';

  @override
  String get helperMaritalStatus => 'Afeta o cálculo do escalão de IRS';

  @override
  String get helperMealObjective =>
      'Define o padrão alimentar: omnívoro, vegetariano, pescatariano, etc.';

  @override
  String get helperSodiumPreference =>
      'Filtra receitas pelo nível de teor de sódio';

  @override
  String subtitleDietaryRestriction(String ingredient) {
    return 'Exclui receitas que contêm $ingredient';
  }

  @override
  String subtitleExcludedProtein(String protein) {
    return 'Remove $protein de todas as sugestões de refeições';
  }

  @override
  String subtitleKitchenEquipment(String equipment) {
    return 'Ativa receitas que requerem $equipment';
  }

  @override
  String get helperVeggieDays =>
      'Número de dias totalmente vegetarianos por semana';

  @override
  String get helperFishDays => 'Recomendado: 2-3 vezes por semana';

  @override
  String get helperLegumeDays => 'Recomendado: 2-3 vezes por semana';

  @override
  String get helperRedMeatDays => 'Recomendado: máximo 2 vezes por semana';

  @override
  String get helperMaxPrepTime =>
      'Tempo máximo de confeção para refeições de semana (minutos)';

  @override
  String get helperMaxComplexity =>
      'Nível de dificuldade das receitas para dias de semana';

  @override
  String get helperWeekendPrepTime =>
      'Tempo máximo de confeção para refeições de fim de semana (minutos)';

  @override
  String get helperWeekendComplexity =>
      'Nível de dificuldade das receitas para fins de semana';

  @override
  String get helperMaxBatchDays =>
      'Quantos dias uma refeição preparada em lote pode ser reutilizada';

  @override
  String get helperNewIngredients =>
      'Limita quantos ingredientes novos aparecem por semana';

  @override
  String get helperGrossSalary => 'Salário total antes de impostos e deduções';

  @override
  String get helperExemptIncome =>
      'Rendimento adicional não sujeito a IRS (ex.: subsídios)';

  @override
  String get helperMealAllowance => 'Subsídio de refeição diário do empregador';

  @override
  String get helperWorkingDays =>
      'Típico: 22. Afeta o cálculo do subsídio de refeição';

  @override
  String get helperSalaryLabel =>
      'Um nome para identificar esta fonte de rendimento';

  @override
  String get helperExpenseAmount =>
      'Montante mensal orçamentado para esta categoria';

  @override
  String get helperCalorieTarget => 'Recomendado: 2000-2500 kcal para adultos';

  @override
  String get helperProteinTarget => 'Recomendado: 50-70g para adultos';

  @override
  String get helperFiberTarget => 'Recomendado: 25-30g para adultos';

  @override
  String get infoStressIndex =>
      'Compara os gastos reais com o seu orçamento. Intervalos de pontuação:\n\n0-30: Confortável - gastos bem dentro do orçamento\n30-60: Moderado - a aproximar-se dos limites do orçamento\n60-100: Crítico - gastos excedem significativamente o orçamento';

  @override
  String get infoBudgetStreak =>
      'Meses consecutivos em que a despesa total ficou dentro do orçamento total.';

  @override
  String get infoUpcomingBills =>
      'Mostra despesas recorrentes nos próximos 30 dias com base nas suas despesas mensais.';

  @override
  String get infoSalaryBreakdown =>
      'Mostra como o salário bruto é dividido em imposto IRS, contribuições para a segurança social, rendimento líquido e subsídio de refeição.';

  @override
  String get infoBudgetVsActual =>
      'Compara o que orçamentou por categoria com o que realmente gastou. Verde significa abaixo do orçamento, vermelho significa acima do orçamento.';

  @override
  String get infoSavingsGoals =>
      'Progresso em relação a cada objetivo de poupança com base nas contribuições efetuadas.';

  @override
  String get infoTaxDeductions =>
      'Despesas dedutíveis estimadas (saúde, educação, habitação). Estas são apenas estimativas - consulte um profissional fiscal para valores precisos.';

  @override
  String get infoPurchaseHistory =>
      'Total gasto em compras da lista de compras este mês.';

  @override
  String get infoExpensesBreakdown =>
      'Discriminação visual das suas despesas por categoria no mês atual.';

  @override
  String get infoCharts =>
      'Dados de tendência ao longo do tempo. Toque em qualquer gráfico para uma vista detalhada.';

  @override
  String get infoExpenseTrackerSummary =>
      'Orçamentado = despesa mensal planeada. Real = o que gastou até agora. Restante = orçamento menos real.';

  @override
  String get infoExpenseTrackerProgress =>
      'Verde: abaixo de 75% do orçamento. Amarelo: 75-100%. Vermelho: acima do orçamento.';

  @override
  String get infoExpenseTrackerFilter =>
      'Filtre despesas por texto, categoria ou intervalo de datas.';

  @override
  String get infoSavingsProjection =>
      'Baseado nas suas contribuições mensais médias. \"No caminho certo\" significa que o ritmo atual atinge o objetivo no prazo. \"Atrasado\" significa que precisa de aumentar as contribuições.';

  @override
  String get infoSavingsRequired =>
      'O montante que precisa de poupar por mês a partir de agora para atingir o objetivo no prazo.';

  @override
  String get infoCoachModes =>
      'Eco: gratuito, sem memória de conversa.\nPlus: 1 crédito por mensagem, lembra as últimas 5 mensagens.\nPro: 2 créditos por mensagem, memória de conversa completa.';

  @override
  String get infoCoachCredits =>
      'Os créditos são usados nos modos Plus e Pro. Recebe créditos iniciais ao registar-se. O modo Eco é sempre gratuito.';

  @override
  String get helperWizardGrossSalary =>
      'O seu salário mensal total antes de impostos';

  @override
  String get helperWizardMealAllowance =>
      'Subsídio de refeição diário do empregador (se aplicável)';

  @override
  String get helperWizardRent => 'Pagamento mensal de habitação';

  @override
  String get helperWizardGroceries =>
      'Orçamento mensal de alimentação e produtos domésticos';

  @override
  String get helperWizardTransport =>
      'Custos mensais de transporte (combustível, transportes públicos, etc.)';

  @override
  String get helperWizardUtilities => 'Eletricidade, água e gás mensais';

  @override
  String get helperWizardTelecom => 'Internet, telefone e TV mensais';

  @override
  String get savingsGoalHowItWorksTitle => 'Como funciona?';

  @override
  String get savingsGoalHowItWorksStep1 =>
      'Crie um objetivo com um nome e o valor que pretende atingir (ex: \"Férias â€” 2 000 â‚¬\").';

  @override
  String get savingsGoalHowItWorksStep2 =>
      'Opcionalmente defina uma data limite para ter um prazo de referência.';

  @override
  String get savingsGoalHowItWorksStep3 =>
      'Sempre que poupar dinheiro, toque no objetivo e registe uma contribuição com o valor e a data.';

  @override
  String get savingsGoalHowItWorksStep4 =>
      'Acompanhe o progresso: a barra mostra quanto já poupou e a projeção estima quando atingirá o objetivo.';

  @override
  String get savingsGoalDashboardHint =>
      'Toque num objetivo para ver detalhes e registar contribuições.';

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
  String get planningExportMealPlan => 'Exportar plano de refeições';

  @override
  String get planningImportMealPlan => 'Importar plano de refeições';

  @override
  String get planningExportPantry => 'Exportar despensa';

  @override
  String get planningImportPantry => 'Importar despensa';

  @override
  String get planningExportFreeformMeals => 'Exportar refeições livres';

  @override
  String get planningImportFreeformMeals => 'Importar refeições livres';

  @override
  String get planningFormatCsv => 'CSV';

  @override
  String get planningFormatJson => 'JSON';

  @override
  String get planningImportSuccess => 'Importado com sucesso';

  @override
  String planningImportError(String error) {
    return 'Importação falhou: $error';
  }

  @override
  String get planningExportSuccess => 'Exportado com sucesso';

  @override
  String get planningDataPortability => 'Portabilidade de dados';

  @override
  String get planningDataPortabilityDesc =>
      'Importar e exportar artefactos de planeamento';

  @override
  String get mealBudgetInsightTitle => 'Visão do Orçamento';

  @override
  String get mealBudgetStatusSafe => 'No caminho';

  @override
  String get mealBudgetStatusWatch => 'Atenção';

  @override
  String get mealBudgetStatusOver => 'Acima do orçamento';

  @override
  String get mealBudgetWeeklyCost => 'Custo semanal estimado';

  @override
  String get mealBudgetProjectedMonthly => 'Projeção mensal';

  @override
  String get mealBudgetMonthlyBudget => 'Orçamento mensal de alimentação';

  @override
  String get mealBudgetRemaining => 'Orçamento restante';

  @override
  String get mealBudgetTopExpensive => 'Refeições mais caras';

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
  String get mealBudgetDailyBreakdown => 'Custo diário detalhado';

  @override
  String get mealBudgetShoppingImpact => 'Impacto nas compras';

  @override
  String get mealBudgetUniqueIngredients => 'Ingredientes únicos';

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
  String get confidenceCenterTitle => 'Centro de Confiança';

  @override
  String get confidenceSyncHealth => 'Estado de Sincronização';

  @override
  String get confidenceDataAlerts => 'Alertas de Qualidade dos Dados';

  @override
  String get confidenceRecommendedActions => 'Ações Recomendadas';

  @override
  String get confidenceCenterSubtitle =>
      'Frescura dos dados e saúde do sistema';

  @override
  String get confidenceCenterTile => 'Centro de Confiança';

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
  String get pantryMarkAtHome => 'Já tenho em casa';

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
    return '$name removido da lista (já em casa)';
  }

  @override
  String pantryMarkedAtHome(String name) {
    return '$name marcado como já em casa';
  }

  @override
  String get householdActivityTitle => 'Atividade do Agregado';

  @override
  String get householdActivityFilterAll => 'Tudo';

  @override
  String get householdActivityFilterShopping => 'Compras';

  @override
  String get householdActivityFilterMeals => 'Refeições';

  @override
  String get householdActivityFilterExpenses => 'Despesas';

  @override
  String get householdActivityFilterPantry => 'Despensa';

  @override
  String get householdActivityFilterSettings => 'Definições';

  @override
  String get householdActivityEmpty => 'Sem atividade';

  @override
  String get householdActivityEmptyMessage =>
      'As ações partilhadas do seu agregado aparecerão aqui.';

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
    return '$count min atrás';
  }

  @override
  String householdActivityHoursAgo(int count) {
    return '${count}h atrás';
  }

  @override
  String householdActivityDaysAgo(int count) {
    return '${count}d atrás';
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
      'Este é um código de fatura, não de produto';

  @override
  String get barcodeInvoiceAction => 'Abrir Scanner de Recibos';

  @override
  String get quickAddTooltip => 'Ações rápidas';

  @override
  String get quickAddExpense => 'Adicionar despesa';

  @override
  String get quickAddShopping => 'Adicionar item de compras';

  @override
  String get quickOpenMeals => 'Planeador de refeições';

  @override
  String get quickOpenAssistant => 'Assistente';

  @override
  String get freeformBadge => 'Livre';

  @override
  String get freeformCreateTitle => 'Adicionar refeição livre';

  @override
  String get freeformEditTitle => 'Editar refeição livre';

  @override
  String get freeformTitleLabel => 'Título da refeição';

  @override
  String get freeformTitleHint => 'ex. Sobras, Pizza de takeaway';

  @override
  String get freeformNoteLabel => 'Nota (opcional)';

  @override
  String get freeformNoteHint => 'Detalhes sobre esta refeição';

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
  String get freeformTagQuickMeal => 'Refeição rápida';

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
  String get freeformItemPrice => 'Preço est.';

  @override
  String get freeformItemStore => 'Loja';

  @override
  String freeformShoppingItemCount(int count) {
    return '$count itens de compras';
  }

  @override
  String get freeformAddToSlot => 'Adicionar refeição livre';

  @override
  String get freeformReplace => 'Substituir por refeição livre';

  @override
  String get insightsTitle => 'Análise';

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
      'Abrir painel financeiro completo com todos os cartões';

  @override
  String get moreSavingsSubtitle =>
      'Acompanhar e atualizar o progresso das metas';

  @override
  String get moreNotificationsSubtitle => 'Orçamentos, contas e lembretes';

  @override
  String get moreSettingsSubtitle => 'Preferências, perfil e painel';

  @override
  String get morePlanFree => 'Plano Grátis';

  @override
  String get morePlanTrial => 'Período de Teste Ativo';

  @override
  String get morePlanPro => 'Plano Pro';

  @override
  String get morePlanFamily => 'Plano Família';

  @override
  String get morePlanManage => 'Gerir o teu plano e faturação';

  @override
  String morePlanLimits(int categories, int goals) {
    return '$categories categorias • $goals meta de poupança';
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
  String get planGrocerySubtitle => 'Explorar produtos e preços';

  @override
  String get planShoppingList => 'Lista de Compras';

  @override
  String get planShoppingSubtitle => 'Rever e finalizar compras';

  @override
  String get planMealSubtitle => 'Gerar planos semanais acessíveis';

  @override
  String coachActiveMemory(String mode, int percent) {
    return 'Memória ativa: $mode ($percent%)';
  }

  @override
  String get coachCostPerMessageNote =>
      'Custo por mensagem enviada. A resposta do coach não consome créditos.';

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
  String get featureNameMealPlanner => 'Planeador de Refeições';

  @override
  String get featureNameExpenseTracker => 'Rastreador de Despesas';

  @override
  String get featureNameSavingsGoals => 'Metas de Poupança';

  @override
  String get featureNameShoppingList => 'Lista de Compras';

  @override
  String get featureNameGroceryBrowser => 'Explorador de Produtos';

  @override
  String get featureNameExportReports => 'Exportar Relatórios';

  @override
  String get featureNameTaxSimulator => 'Simulador Fiscal';

  @override
  String get featureNameDashboard => 'Painel';

  @override
  String get featureTagAiCoach => 'O teu consultor financeiro pessoal';

  @override
  String get featureTagMealPlanner => 'Poupa dinheiro na alimentação';

  @override
  String get featureTagExpenseTracker => 'Sabe para onde vai cada euro';

  @override
  String get featureTagSavingsGoals => 'Concretiza os teus sonhos';

  @override
  String get featureTagShoppingList => 'Compra de forma mais inteligente';

  @override
  String get featureTagGroceryBrowser => 'Compara preços instantaneamente';

  @override
  String get featureTagExportReports => 'Relatórios profissionais de orçamento';

  @override
  String get featureTagTaxSimulator => 'Planeamento fiscal multi-país';

  @override
  String get featureTagDashboard => 'A tua visão financeira geral';

  @override
  String get featureDescAiCoach =>
      'Obtém insights personalizados sobre os teus hábitos de gastos, dicas de poupança e otimização do orçamento com IA.';

  @override
  String get featureDescMealPlanner =>
      'Planeia refeições semanais dentro do teu orçamento. A IA gera receitas com base nas tuas preferências e necessidades alimentares.';

  @override
  String get featureDescExpenseTracker =>
      'Acompanha despesas reais vs. orçamento em tempo real. Vê onde gastas demais e onde podes poupar.';

  @override
  String get featureDescSavingsGoals =>
      'Define metas de poupança com prazos, acompanha contribuições e vê projeções de quando atingirás os teus objetivos.';

  @override
  String get featureDescShoppingList =>
      'Cria listas de compras partilhadas em tempo real. Marca itens enquanto compras, finaliza e acompanha gastos.';

  @override
  String get featureDescGroceryBrowser =>
      'Explora produtos de várias lojas, compara preços e adiciona as melhores ofertas diretamente Ã  tua lista de compras.';

  @override
  String get featureDescExportReports =>
      'Exporta o teu orçamento, despesas e resumos financeiros em PDF ou CSV para os teus registos ou contabilista.';

  @override
  String get featureDescTaxSimulator =>
      'Compara obrigações fiscais entre países. Perfeito para expatriados e quem considera mudança de país.';

  @override
  String get featureDescDashboard =>
      'Vê o resumo completo do orçamento, gráficos e saúde financeira de relance.';

  @override
  String get trialPremiumActive => 'Período de Teste Premium Ativo';

  @override
  String get trialHalfway => 'O teu período de teste está a meio';

  @override
  String trialDaysLeftInTrial(int count) {
    return '$count dias restantes no teu período de teste!';
  }

  @override
  String get trialLastDay => 'Ãšltimo dia do teu período de teste grátis!';

  @override
  String get trialSeePlans => 'Ver Planos';

  @override
  String get trialUpgradeNow => 'Upgrade Agora — Mantém os Teus Dados';

  @override
  String get trialSubtitleUrgent =>
      'O teu acesso premium termina em breve. Faz upgrade para manter o Coach IA, Planeador de Refeições e todos os teus dados.';

  @override
  String trialSubtitleMidFeature(String name) {
    return 'Já experimentaste o $name? Aproveita ao máximo o teu período de teste!';
  }

  @override
  String get trialSubtitleMidProgress =>
      'Estás a fazer ótimo progresso! Continua a explorar funcionalidades premium.';

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
  String get receiptScanHint => 'Aponte a câmara para o QR code do recibo';

  @override
  String get receiptScanPhotoHint =>
      'Posicione o recibo e toque no botão para capturar';

  @override
  String get receiptScanProcessing => 'A ler reciboâ€¦';

  @override
  String receiptScanSuccess(String amount, String store) {
    return 'Despesa de $amount no $store registada';
  }

  @override
  String get receiptScanFailed => 'Não foi possível ler o recibo';

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
  String get receiptCameraPermissionTitle => 'Acesso Ã  Câmara';

  @override
  String get receiptCameraPermissionBody =>
      'Ã‰ necessário acesso Ã  câmara para digitalizar recibos e códigos de barras.';

  @override
  String get receiptCameraPermissionAllow => 'Permitir';

  @override
  String get receiptCameraPermissionDeny => 'Agora não';

  @override
  String get receiptCameraBlockedTitle => 'Câmara Bloqueada';

  @override
  String get receiptCameraBlockedBody =>
      'A permissão da câmara foi negada permanentemente. Abra as definições para a ativar.';

  @override
  String get receiptCameraBlockedSettings => 'Abrir Definições';

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
  String get navHome => 'Início';

  @override
  String get navHomeTip => 'Resumo mensal';

  @override
  String get navTrack => 'Despesas';

  @override
  String get navTrackTip => 'Registar despesas mensais';

  @override
  String get navPlan => 'Planear';

  @override
  String get navPlanTip => 'Mercearia, lista e plano de refeições';

  @override
  String get navPlanAndShop => 'Compras';

  @override
  String get navPlanAndShopTip => 'Lista de compras, mercearia e refeições';

  @override
  String get navMore => 'Mais';

  @override
  String get navMoreTip => 'Definições e análises';

  @override
  String get paywallContinueFree => 'A continuar com o plano gratuito';

  @override
  String get paywallUpgradedPro => 'Atualizado para Pro â€” obrigado!';

  @override
  String get paywallNoRestore => 'Nenhuma compra anterior encontrada';

  @override
  String get paywallRestoredPro => 'Subscrição Pro restaurada!';

  @override
  String get subscriptionPro => 'Pro';

  @override
  String subscriptionTrialLabel(int count) {
    return 'Teste ($count dias restantes)';
  }

  @override
  String get authConnectionError => 'Erro de ligação';

  @override
  String get authRetry => 'Tentar novamente';

  @override
  String get authSignOut => 'Terminar sessão';

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
  String get settingsManageSubscription => 'Gerir Subscrição';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get mealShowDetails => 'Mostrar detalhes';

  @override
  String get mealHideDetails => 'Ocultar detalhes';

  @override
  String get taxSimTitularesHint =>
      'Número de titulares de rendimento no agregado familiar';

  @override
  String get taxSimMealTypeHint =>
      'Cartão: isento de imposto até ao limite legal. Dinheiro: tributado como rendimento.';

  @override
  String get taxSimIRSFull => 'IRS (Imposto sobre o Rendimento) retenção';

  @override
  String get taxSimSSFull => 'SS (Segurança Social)';

  @override
  String get stressZoneCritical =>
      '0â€“39: Pressão financeira elevada, ação urgente necessária';

  @override
  String get stressZoneWarning =>
      '40â€“59: Alguns riscos presentes, melhorias recomendadas';

  @override
  String get stressZoneGood =>
      '60â€“79: Finanças saudáveis, pequenas otimizações possíveis';

  @override
  String get stressZoneExcellent =>
      '80â€“100: Posição financeira forte, bem gerida';

  @override
  String get projectionStressHint =>
      'Como este cenário de gastos afeta a sua pontuação geral de saúde financeira (0â€“100)';

  @override
  String get coachWelcomeTitle => 'O Seu Coach Financeiro IA';

  @override
  String get coachWelcomeBody =>
      'Faça perguntas sobre o seu orçamento, despesas ou poupanças. O coach analisa os seus dados financeiros reais para dar conselhos personalizados.';

  @override
  String get coachWelcomeCredits =>
      'Os créditos são usados nos modos Plus e Pro. O modo Eco é sempre gratuito.';

  @override
  String get coachWelcomeRateLimit =>
      'Para garantir respostas de qualidade, existe um breve intervalo entre mensagens.';

  @override
  String get planMealsProBadge => 'PRO';

  @override
  String get coachBuyCredits => 'Comprar créditos';

  @override
  String get coachContinueEco => 'Continuar com Eco';

  @override
  String get coachAchieved => 'Consegui!';

  @override
  String get coachNotYet => 'Ainda não';

  @override
  String coachCreditsAdded(int count) {
    return '+$count créditos adicionados';
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
  String get settingsSubscription => 'Subscrição';

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
  String get configurationError => 'Erro de Configuração';

  @override
  String get confidenceAllHealthy =>
      'Todos os sistemas saudáveis. Nenhuma ação necessária.';

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
      'Gráfico de tendências de despesas mostrando orçamento versus gastos reais';

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
  String get customCategoryInUse => 'Categoria em uso, não pode ser eliminada';

  @override
  String get customCategoryPredefinedHint =>
      'Categorias predefinidas usadas em toda a aplicação';

  @override
  String get customCategoryDefault => 'Predefinida';

  @override
  String get expenseLocationPermissionDenied =>
      'Permissão de localização negada';

  @override
  String get expenseAttachPhoto => 'Anexar Foto';

  @override
  String get expenseAttachCamera => 'Câmara';

  @override
  String get expenseAttachGallery => 'Galeria';

  @override
  String get expenseAttachUploadFailed =>
      'Falha ao carregar anexos. Verifique a sua ligação.';

  @override
  String get expenseExtras => 'Extras';

  @override
  String get expenseLocationDetect => 'Detetar localização';

  @override
  String get biometricLockTitle => 'Bloqueio da App';

  @override
  String get biometricLockSubtitle =>
      'Exigir autenticação ao abrir a aplicação';

  @override
  String get biometricPrompt => 'Autentique-se para continuar';

  @override
  String get biometricReason =>
      'Verifique a sua identidade para desbloquear a aplicação';

  @override
  String get biometricRetry => 'Tentar Novamente';

  @override
  String get notifDailyExpenseReminder => 'Lembrete diário de despesas';

  @override
  String get notifDailyExpenseReminderDesc =>
      'Lembra-o de registar as despesas do dia';

  @override
  String get notifDailyExpenseTitle => 'Não se esqueça das despesas!';

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
  String get expenseLocationSearchHint => 'Pesquisar endereço...';

  @override
  String get dashboardBurnRateTitle => 'Velocidade de Gasto';

  @override
  String get dashboardBurnRateSubtitle =>
      'Média diária vs orçamento disponível';

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
      'Categorias com mais despesas este mês';

  @override
  String get dashboardCashFlowTitle => 'Previsão de Fluxo';

  @override
  String get dashboardCashFlowSubtitle => 'Projeção de saldo até ao fim do mês';

  @override
  String get dashboardCashFlowProjectedSpend => 'GASTO PROJETADO';

  @override
  String get dashboardCashFlowEndOfMonth => 'FIM DO MÃŠS';

  @override
  String dashboardCashFlowPendingBills(String amount) {
    return 'Contas pendentes: $amount';
  }

  @override
  String get dashboardSavingsRateTitle => 'Taxa de Poupança';

  @override
  String get dashboardSavingsRateSubtitle =>
      'Percentagem do rendimento poupada';

  @override
  String dashboardSavingsRateSaved(String amount) {
    return 'Poupado este mês: $amount';
  }

  @override
  String get dashboardCoachInsightTitle => 'Dica Financeira';

  @override
  String get dashboardCoachInsightSubtitle =>
      'Sugestão personalizada do assistente financeiro';

  @override
  String get dashboardCoachLowSavings =>
      'A sua taxa de poupança está abaixo de 10%. Identifique uma despesa que pode reduzir este mês.';

  @override
  String get dashboardCoachHighSpending =>
      'Os gastos estão a aproximar-se do rendimento. Reveja as despesas não essenciais.';

  @override
  String get dashboardCoachGoodSavings =>
      'Excelente! Está a poupar mais de 20%. Continue assim!';

  @override
  String get dashboardCoachGeneral =>
      'Toque para obter análises personalizadas do seu orçamento.';

  @override
  String get dashGroupInsights => 'Análise';

  @override
  String get dashReorderHint => 'Arraste para reordenar os cartões';

  @override
  String get settingsSalarySummaryGross => 'Bruto';

  @override
  String get settingsSalarySummaryNet => 'Líquido';

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
    return '$oldName substituído por $newName';
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
  String get nutritionDashboardTitle => 'Nutrição Semanal';

  @override
  String get nutritionCalories => 'Calorias';

  @override
  String get nutritionProtein => 'Proteína';

  @override
  String get nutritionCarbs => 'Hidratos';

  @override
  String get nutritionFat => 'Gordura';

  @override
  String get nutritionFiber => 'Fibra';

  @override
  String get nutritionTopProteins => 'Top proteínas';

  @override
  String get nutritionDailyAvg => 'Média diária';

  @override
  String get mealWasteEstimate => 'Desperdício estimado';

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
    return '~$cost em desperdício';
  }
}
