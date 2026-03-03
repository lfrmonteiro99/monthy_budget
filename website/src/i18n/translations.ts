export type Locale = "pt" | "en" | "es" | "fr";

export interface TranslationKeys {
  skip_link: string;
  nav_home: string;
  nav_features: string;
  nav_screens: string;
  nav_privacy: string;
  nav_terms: string;
  nav_usecases: string;
  nav_theme_aria: string;
  nav_lang_aria: string;
  hero_badge: string;
  hero_title_line1: string;
  hero_title_line2: string;
  hero_subtitle: string;
  hero_cta_primary: string;
  hero_cta_secondary: string;
  stat_features_label: string;
  stat_screens_label: string;
  stat_languages_label: string;
  stat_free_label: string;
  mockup_title: string;
  mockup_net_label: string;
  mockup_expenses_label: string;
  mockup_savings_label: string;
  mockup_trend_label: string;
  mockup_label: string;
  float1: string;
  float2: string;
  float3: string;
  trust1: string;
  trust2: string;
  trust3: string;
  trust4: string;
  features_title: string;
  features_desc: string;
  feat1_title: string;
  feat1_desc: string;
  feat2_title: string;
  feat2_desc: string;
  feat3_title: string;
  feat3_desc: string;
  feat4_title: string;
  feat4_desc: string;
  feat5_title: string;
  feat5_desc: string;
  feat6_title: string;
  feat6_desc: string;
  screens_title: string;
  screens_desc: string;
  screen1_title: string;
  screen1_desc: string;
  screen2_title: string;
  screen2_desc: string;
  screen3_title: string;
  screen3_desc: string;
  screen4_title: string;
  screen4_desc: string;
  screen5_title: string;
  screen5_desc: string;
  cta_title: string;
  cta_desc: string;
  cta_button: string;
  footer_desc: string;
  footer_app_heading: string;
  footer_legal_heading: string;
  footer_feat_link: string;
  footer_screens_link: string;
  footer_download_link: string;
  footer_privacy_link: string;
  footer_terms_link: string;
  footer_copyright: string;
  footer_made_in: string;
  timeline_title: string;
  timeline_subtitle: string;
  timeline_day1_title: string;
  timeline_day1_pain: string;
  timeline_day1_resolution: string;
  timeline_day5_title: string;
  timeline_day5_pain: string;
  timeline_day5_resolution: string;
  timeline_day9_title: string;
  timeline_day9_pain: string;
  timeline_day9_resolution: string;
  timeline_day14_title: string;
  timeline_day14_pain: string;
  timeline_day14_resolution: string;
  timeline_day18_title: string;
  timeline_day18_pain: string;
  timeline_day18_resolution: string;
  timeline_day25_title: string;
  timeline_day25_pain: string;
  timeline_day25_resolution: string;
  timeline_day30_title: string;
  timeline_day30_pain: string;
  timeline_day30_resolution: string;
  privacy_title: string;
  privacy_last_updated: string;
  terms_title: string;
  terms_last_updated: string;
}

export const translations: Record<Locale, TranslationKeys> = {
  pt: {
    skip_link: "Saltar para o conteúdo",
    nav_home: "Início",
    nav_features: "Funcionalidades",
    nav_screens: "Ecrãs",
    nav_privacy: "Privacidade",
    nav_terms: "Termos",
    nav_usecases: "Casos de Uso",
    nav_theme_aria: "Alternar modo escuro",
    nav_lang_aria: "Idioma",
    hero_badge: "100% grátis para Android — sem letras pequenas",
    hero_title_line1: "O teu dinheiro deixou",
    hero_title_line2: "de te tirar o sono",
    hero_subtitle: "Milhares de famílias portuguesas já controlam o IRS, as compras e cada cêntimo do mês. Junta-te a elas com a app gratuita que muda tudo.",
    hero_cta_primary: "Descarregar Grátis na Google Play",
    hero_cta_secondary: "Descobre Como Funciona",
    stat_features_label: "Funcionalidades",
    stat_screens_label: "Ecrãs",
    stat_languages_label: "Idiomas",
    stat_free_label: "Gratuita",
    mockup_title: "Orçamento Mensal",
    mockup_net_label: "Rendimento Líquido",
    mockup_expenses_label: "Despesas",
    mockup_savings_label: "Poupança",
    mockup_trend_label: "Tendência Mensal",
    mockup_label: "Dashboard",
    float1: "+€619 poupados este mês!",
    float2: "Despesas 100% controladas",
    float3: "Orçamento blindado e seguro",
    trust1: "Dados seguros no teu telemóvel",
    trust2: "Zero anúncios. Para sempre.",
    trust3: "100% gratuita — sem custos escondidos",
    trust4: "Privacidade protegida pelo RGPD",
    features_title: "Pára de sobreviver ao mês. Começa a dominá-lo.",
    features_desc: "Cada funcionalidade foi criada para eliminar um problema real que já te tirou o sono.",
    feat1_title: "Orçamento Que Trabalha Por Ti",
    feat1_desc: "Sabes para onde vai cada euro antes de o gastares. Receitas, despesas e categorias ao cêntimo — acabaram-se as surpresas ao fim do mês.",
    feat2_title: "IRS Calculado ao Cêntimo",
    feat2_desc: "Esquece folhas de Excel e simuladores duvidosos. Tabelas de IRS portuguesas integradas — vês o teu rendimento líquido real num instante.",
    feat3_title: "Compras Sem Sustos na Caixa",
    feat3_desc: "Entra no supermercado com uma lista e preços reais. Sabes o total antes de saíres de casa — acabou a ansiedade no corredor.",
    feat4_title: "Toda a Família na Mesma Página",
    feat4_desc: "Partilha o orçamento com quem vive contigo. Decisões financeiras deixam de ser uma guerra e passam a ser uma equipa.",
    feat5_title: "Refeições Planeadas, Carteira Protegida",
    feat5_desc: "30 dias de refeições que cabem no teu orçamento. Ingredientes agrupados, custos calculados — acabou o improviso que rebenta a conta.",
    feat6_title: "Coach Financeiro Que Te Conhece",
    feat6_desc: "Conselhos personalizados com base nos teus hábitos reais. A IA analisa os teus padrões e ajuda-te a poupar sem abdicar do que gostas.",
    screens_title: "5 ecrãs. Zero confusão. Controlo absoluto.",
    screens_desc: "Cada ecrã dá-te respostas em segundos — não mais perguntas.",
    screen1_title: "Dashboard",
    screen1_desc: "Abre a app e vê em segundos se o mês está no verde ou no vermelho.",
    screen2_title: "Supermercado",
    screen2_desc: "Preços reais dos produtos que compras — compara e poupa sem esforço.",
    screen3_title: "Lista de Compras",
    screen3_desc: "Partilhada com a família e atualizada em tempo real — ninguém compra a mais.",
    screen4_title: "Refeições",
    screen4_desc: "Acabou o eterno 'o que vamos jantar?' — o plano semanal decide por ti.",
    screen5_title: "Coach IA",
    screen5_desc: "O teu consultor financeiro de bolso, disponível 24h por dia.",
    cta_title: "O próximo mês pode ser diferente. Começa hoje.",
    cta_desc: "Famílias em todo o país já recuperaram o controlo das finanças. Grátis, sem anúncios, feita em Portugal para ti.",
    cta_button: "Descarregar Grátis na Google Play",
    footer_desc: "A app que está a transformar a forma como as famílias portuguesas vivem o dinheiro.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Funcionalidades",
    footer_screens_link: "Ecrãs",
    footer_download_link: "Descarregar",
    footer_privacy_link: "Política de Privacidade",
    footer_terms_link: "Termos de Utilização",
    footer_copyright: "© 2026 Gestão Mensal. Todos os direitos reservados.",
    footer_made_in: "Feito com cuidado em Portugal",
    timeline_title: "30 dias que viraram a vida da Maria do avesso",
    timeline_subtitle: "Um mês inteiro. Desafios reais. Vitórias que mudam tudo. Acompanha cada passo.",
    timeline_day1_title: "\u201CO dinheiro evapora e eu nem sei como\u201D",
    timeline_day1_pain: "Maria senta-se, nervosa, com uma pilha de extratos e recibos. Sempre que tenta perceber quanto pode gastar, acaba confusa e desconfortável.",
    timeline_day1_resolution: "Com a app, em 5-10 minutos, ela introduz os seus rendimentos e despesas principais. A app mostra-lhe o mês inteiro antes de começar a gastar — quanto entra, quanto sai, e onde normalmente o dinheiro evapora. Pela primeira vez em muito tempo, ela sente que tem a sua vida financeira sob controlo.",
    timeline_day5_title: "\u201CChega de multas. Chega de pânico.\u201D",
    timeline_day5_pain: "Sempre que se aproxima a data de uma conta, Maria sente aquele apertar no estômago: medo de multas, de falhar, de penalizações. O stress cria uma ansiedade constante.",
    timeline_day5_resolution: "A app envia um lembrete antecipado para a conta do gás que vence amanhã. Maria paga a tempo, sem nervos, sem medo. Um pequeno alerta faz com que o stress desapareça.",
    timeline_day9_title: "\u201CO caos das refeições acabou de vez\u201D",
    timeline_day9_pain: "A verdade é que decidir refeições todos os dias acaba sempre por se tornar uma batalha: ou te decides por impulso, ou acabas por gastar mais na loja e tens aquela sensação de culpa.",
    timeline_day9_resolution: "O plano de refeições semanal está pronto. A lista de compras é gerada automaticamente com base no orçamento que ela definiu. Entrar no supermercado deixa de ser um momento tenso — é agora uma experiência clara, organizada e sem decisões impulsivas.",
    timeline_day14_title: "\u201CMetade do mês e o orçamento está a derrapar\u201D",
    timeline_day14_pain: "Metade do mês passou e Maria vê que uma grande parte do orçamento foi gasta em restaurantes. Isso traz culpa, insegurança e aquela sensação de 'não chega'. Em termos comportamentais, isto é comum — stress pode levar a decisões de gasto impulsivas quando não há estrutura.",
    timeline_day14_resolution: "A app mostra um aviso de ritmo de gastos e explica claramente o impacto no orçamento. Maria e João decidem cozinhar mais em casa este fim de semana — não por obrigação, mas por sentirem que estão novamente no comando das suas escolhas.",
    timeline_day18_title: "\u201CEntrar no supermercado sem medo — finalmente\u201D",
    timeline_day18_pain: "Antes, Maria entrava no supermercado sem saber ao certo quanto iria gastar — e isso gerava ansiedade, medo de ultrapassar o orçamento e decisões impulsivas no carrinho. Estudos mostram que uma lista bem planeada ajuda a reduzir despesa e desperdício simplesmente ao focar a compra no que é realmente necessário.",
    timeline_day18_resolution: "Hoje, Maria abre a app e vê uma lista de compras construída com os produtos que planeou para as refeições, com os preços médios associados que a app guarda com base nos dados que o próprio utilizador introduziu ou consultou ao longo do tempo. Em vez de adivinhar, ela vê um valor estimado total para a sua compra antes de sair de casa. Ao construir a lista, Maria sabe exatamente quanto costuma valer cada item e como isso soma ao total previsto da compra. Entrar no supermercado deixa de ser um salto no escuro e passa a ser uma tarefa consciente: ela vê o impacto estimado no orçamento e toma decisões no carrinho com confiança, reduzindo stress e ajudando-a a manter o plano financeiro que definiu no início do mês.",
    timeline_day25_title: "\u201CRenda, propinas, seguro — tudo pago. Respira fundo.\u201D",
    timeline_day25_pain: "A ansiedade baixa no final do mês é real e poderosa: \u201CE se faltar dinheiro para a renda? Para as propinas? Para o seguro?\u201D",
    timeline_day25_resolution: "O dashboard mostra quanto resta em cada categoria. Maria vê que ainda tem €120 para educação, e isso traz uma paz de espírito que ela não sentia há anos. Já não é adivinhação — é confiança apoiada nos dados.",
    timeline_day30_title: "\u201C€180 poupados — sem sacrifício, sem culpa\u201D",
    timeline_day30_pain: "No passado, acabar o mês com algum dinheiro parecia impossível. Sempre havia um aperto, um stress final.",
    timeline_day30_resolution: "Agora Maria vê €180 poupados. A app mostra uma sequência de hábitos saudáveis e dá sugestões para reforçar um fundo de emergência. Pela primeira vez, poupar não foi um sacrifício — foi algo que aconteceu sem que ela tivesse de se castigar por isso.",
    privacy_title: "Política de Privacidade",
    privacy_last_updated: "Última atualização: 3 de março de 2026",
    terms_title: "Termos de Utilização",
    terms_last_updated: "Última atualização: 3 de março de 2026",
  },

  en: {
    skip_link: "Skip to content",
    nav_home: "Home",
    nav_features: "Features",
    nav_screens: "Screens",
    nav_privacy: "Privacy",
    nav_terms: "Terms",
    nav_usecases: "Use Cases",
    nav_theme_aria: "Toggle dark mode",
    nav_lang_aria: "Language",
    hero_badge: "100% free on Android — no fine print",
    hero_title_line1: "Your money finally stops",
    hero_title_line2: "keeping you up at night",
    hero_subtitle: "Thousands of families already control their taxes, groceries and every cent of the month. Join them with the free app that changes everything.",
    hero_cta_primary: "Download Free on Google Play",
    hero_cta_secondary: "See How It Works",
    stat_features_label: "Features",
    stat_screens_label: "Screens",
    stat_languages_label: "Languages",
    stat_free_label: "Free",
    mockup_title: "Monthly Budget",
    mockup_net_label: "Net Income",
    mockup_expenses_label: "Expenses",
    mockup_savings_label: "Savings",
    mockup_trend_label: "Monthly Trend",
    mockup_label: "Dashboard",
    float1: "+€619 saved this month!",
    float2: "Expenses 100% on track",
    float3: "Budget locked and secure",
    trust1: "Your data stays on your phone",
    trust2: "Zero ads. Forever.",
    trust3: "100% free — no hidden costs",
    trust4: "Privacy protected by GDPR",
    features_title: "Stop surviving the month. Start owning it.",
    features_desc: "Every feature was built to solve a real problem that already kept you up at night.",
    feat1_title: "A Budget That Works For You",
    feat1_desc: "See where every euro goes before you spend it. Income, expenses and categories down to the cent — no more end-of-month surprises.",
    feat2_title: "Tax Calculated to the Cent",
    feat2_desc: "Forget spreadsheets and unreliable calculators. Portuguese IRS tax tables built in — see your real net income instantly.",
    feat3_title: "Shop Without Checkout Shock",
    feat3_desc: "Walk into the supermarket with a list and real prices. Know the total before you leave home — no more aisle anxiety.",
    feat4_title: "Your Whole Family on the Same Page",
    feat4_desc: "Share your budget with everyone at home. Financial decisions stop being a battle and become teamwork.",
    feat5_title: "Meals Planned, Wallet Protected",
    feat5_desc: "30 days of meals that fit your budget. Grouped ingredients, calculated costs — no more improvising that blows the budget.",
    feat6_title: "A Financial Coach That Knows You",
    feat6_desc: "Personalised advice based on your real habits. AI analyses your patterns and helps you save without giving up what you love.",
    screens_title: "5 screens. Zero confusion. Absolute control.",
    screens_desc: "Each screen gives you answers in seconds — not more questions.",
    screen1_title: "Dashboard",
    screen1_desc: "Open the app and see instantly if your month is in the green or the red.",
    screen2_title: "Supermarket",
    screen2_desc: "Real prices for the products you buy — compare and save effortlessly.",
    screen3_title: "Shopping List",
    screen3_desc: "Shared with family and updated in real time — nobody overbuy.",
    screen4_title: "Meals",
    screen4_desc: "No more 'what's for dinner?' — the weekly plan decides for you.",
    screen5_title: "AI Coach",
    screen5_desc: "Your pocket financial advisor, available 24 hours a day.",
    cta_title: "Next month can be different. Start today.",
    cta_desc: "Families across the country already took back control. Free, no ads, made in Portugal for you.",
    cta_button: "Download Free on Google Play",
    footer_desc: "The app transforming how families experience money.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Features",
    footer_screens_link: "Screens",
    footer_download_link: "Download",
    footer_privacy_link: "Privacy Policy",
    footer_terms_link: "Terms of Use",
    footer_copyright: "© 2026 Gestão Mensal. All rights reserved.",
    footer_made_in: "Made with care in Portugal",
    timeline_title: "30 days that turned Maria's life around",
    timeline_subtitle: "One full month. Real challenges. Life-changing wins. Follow every step.",
    timeline_day1_title: "\u201CMy money vanishes and I have no idea how\u201D",
    timeline_day1_pain: "Maria sits down, anxious, with a pile of statements and receipts. Every time she tries to figure out how much she can spend, she ends up confused and uncomfortable.",
    timeline_day1_resolution: "With the app, in 5-10 minutes, she enters her income and main expenses. The app shows her the entire month before she starts spending — how much comes in, how much goes out, and where money usually evaporates. For the first time in a long while, she feels her financial life is under control.",
    timeline_day5_title: "\u201CNo more late fees. No more panic.\u201D",
    timeline_day5_pain: "Every time a bill due date approaches, Maria feels that knot in her stomach: fear of fines, of failing, of penalties. The stress creates constant anxiety.",
    timeline_day5_resolution: "The app sends an early reminder for the gas bill due tomorrow. Maria pays on time, without nerves, without fear. A small alert makes the stress disappear.",
    timeline_day9_title: "\u201CThe meal chaos is finally over\u201D",
    timeline_day9_pain: "The truth is that deciding meals every day always ends up becoming a battle: either you decide on impulse, or you end up spending more at the store with that feeling of guilt.",
    timeline_day9_resolution: "The weekly meal plan is ready. The shopping list is automatically generated based on the budget she set. Going to the supermarket stops being a tense moment — it\u2019s now a clear, organized experience without impulsive decisions.",
    timeline_day14_title: "\u201CHalf the month gone and the budget is slipping\u201D",
    timeline_day14_pain: "Half the month has passed and Maria sees that a large portion of the budget was spent on restaurants. This brings guilt, insecurity, and that feeling of \u2018it\u2019s not enough\u2019. Behaviorally, this is common — stress can lead to impulsive spending decisions when there\u2019s no structure.",
    timeline_day14_resolution: "The app shows a spending pace alert and clearly explains the impact on the budget. Maria and João decide to cook more at home this weekend — not out of obligation, but because they feel they\u2019re back in control of their choices.",
    timeline_day18_title: "\u201CWalking into the supermarket without fear — finally\u201D",
    timeline_day18_pain: "Before, Maria would enter the supermarket without knowing exactly how much she would spend — and that generated anxiety, fear of exceeding the budget, and impulsive decisions at the cart. Studies show that a well-planned list helps reduce spending and waste simply by focusing the purchase on what\u2019s truly needed.",
    timeline_day18_resolution: "Today, Maria opens the app and sees a shopping list built with the products she planned for meals, with average prices the app stores based on data the user entered or consulted over time. Instead of guessing, she sees an estimated total for her purchase before leaving home.",
    timeline_day25_title: "\u201CRent, tuition, insurance — all covered. Breathe.\u201D",
    timeline_day25_pain: "End-of-month anxiety is real and powerful: \u201CWhat if there\u2019s not enough for rent? For tuition? For insurance?\u201D",
    timeline_day25_resolution: "The dashboard shows how much remains in each category. Maria sees she still has €120 for education, and that brings a peace of mind she hadn\u2019t felt in years. It\u2019s no longer guesswork — it\u2019s confidence backed by data.",
    timeline_day30_title: "\u201C\u20AC180 saved — no sacrifice, no guilt\u201D",
    timeline_day30_pain: "In the past, ending the month with some money seemed impossible. There was always a squeeze, a final stress.",
    timeline_day30_resolution: "Now Maria sees €180 saved. The app shows a streak of healthy habits and gives suggestions to boost an emergency fund. For the first time, saving wasn\u2019t a sacrifice — it was something that happened without her having to punish herself for it.",
    privacy_title: "Privacy Policy",
    privacy_last_updated: "Last updated: March 3, 2026",
    terms_title: "Terms of Use",
    terms_last_updated: "Last updated: March 3, 2026",
  },

  es: {
    skip_link: "Saltar al contenido",
    nav_home: "Inicio",
    nav_features: "Funcionalidades",
    nav_screens: "Pantallas",
    nav_privacy: "Privacidad",
    nav_terms: "Términos",
    nav_usecases: "Casos de Uso",
    nav_theme_aria: "Alternar modo oscuro",
    nav_lang_aria: "Idioma",
    hero_badge: "100% gratis en Android — sin letra peque\u00f1a",
    hero_title_line1: "Tu dinero dej\u00f3 de",
    hero_title_line2: "quitarte el sue\u00f1o",
    hero_subtitle: "Miles de familias ya controlan sus impuestos, compras y cada c\u00e9ntimo del mes. \u00danete a ellas con la app gratuita que lo cambia todo.",
    hero_cta_primary: "Descargar Gratis en Google Play",
    hero_cta_secondary: "Descubre C\u00f3mo Funciona",
    stat_features_label: "Funcionalidades",
    stat_screens_label: "Pantallas",
    stat_languages_label: "Idiomas",
    stat_free_label: "Gratuita",
    mockup_title: "Presupuesto Mensual",
    mockup_net_label: "Ingreso Neto",
    mockup_expenses_label: "Gastos",
    mockup_savings_label: "Ahorros",
    mockup_trend_label: "Tendencia Mensual",
    mockup_label: "Dashboard",
    float1: "+\u20AC619 ahorrados este mes!",
    float2: "Gastos 100% bajo control",
    float3: "Presupuesto blindado y seguro",
    trust1: "Tus datos seguros en tu m\u00f3vil",
    trust2: "Cero anuncios. Para siempre.",
    trust3: "100% gratuita — sin costes ocultos",
    trust4: "Privacidad protegida por RGPD",
    features_title: "Deja de sobrevivir al mes. Empieza a dominarlo.",
    features_desc: "Cada funcionalidad fue creada para eliminar un problema real que ya te quit\u00f3 el sue\u00f1o.",
    feat1_title: "Un Presupuesto Que Trabaja Por Ti",
    feat1_desc: "Sabes a d\u00f3nde va cada euro antes de gastarlo. Ingresos, gastos y categor\u00edas al c\u00e9ntimo — se acabaron las sorpresas a fin de mes.",
    feat2_title: "Impuestos Calculados al C\u00e9ntimo",
    feat2_desc: "Olvida las hojas de Excel y los simuladores dudosos. Tablas IRS portuguesas integradas — ves tu ingreso neto real al instante.",
    feat3_title: "Compras Sin Sustos en Caja",
    feat3_desc: "Entra al supermercado con una lista y precios reales. Sabes el total antes de salir de casa — se acab\u00f3 la ansiedad en el pasillo.",
    feat4_title: "Toda la Familia en la Misma P\u00e1gina",
    feat4_desc: "Comparte el presupuesto con quien vive contigo. Las decisiones financieras dejan de ser una guerra y pasan a ser equipo.",
    feat5_title: "Comidas Planificadas, Cartera Protegida",
    feat5_desc: "30 d\u00edas de comidas que caben en tu presupuesto. Ingredientes agrupados, costes calculados — se acab\u00f3 improvisar y reventar la cuenta.",
    feat6_title: "Un Coach Financiero Que Te Conoce",
    feat6_desc: "Consejos personalizados basados en tus h\u00e1bitos reales. La IA analiza tus patrones y te ayuda a ahorrar sin renunciar a lo que te gusta.",
    screens_title: "5 pantallas. Cero confusi\u00f3n. Control absoluto.",
    screens_desc: "Cada pantalla te da respuestas en segundos — no m\u00e1s preguntas.",
    screen1_title: "Dashboard",
    screen1_desc: "Abre la app y ve al instante si tu mes est\u00e1 en verde o en rojo.",
    screen2_title: "Supermercado",
    screen2_desc: "Precios reales de los productos que compras — compara y ahorra sin esfuerzo.",
    screen3_title: "Lista de la Compra",
    screen3_desc: "Compartida con la familia y actualizada en tiempo real — nadie compra de m\u00e1s.",
    screen4_title: "Comidas",
    screen4_desc: "Se acab\u00f3 el eterno '\u00bfqu\u00e9 cenamos?' — el plan semanal decide por ti.",
    screen5_title: "Coach IA",
    screen5_desc: "Tu asesor financiero de bolsillo, disponible 24 horas al d\u00eda.",
    cta_title: "El pr\u00f3ximo mes puede ser diferente. Empieza hoy.",
    cta_desc: "Familias de todo el pa\u00eds ya recuperaron el control. Gratis, sin anuncios, hecha en Portugal para ti.",
    cta_button: "Descargar Gratis en Google Play",
    footer_desc: "La app que est\u00e1 transformando c\u00f3mo las familias viven el dinero.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Funcionalidades",
    footer_screens_link: "Pantallas",
    footer_download_link: "Descargar",
    footer_privacy_link: "Política de Privacidad",
    footer_terms_link: "Términos de Uso",
    footer_copyright: "© 2026 Gestão Mensal. Todos los derechos reservados.",
    footer_made_in: "Hecho con cuidado en Portugal",
    timeline_title: "30 d\u00edas que le dieron la vuelta a la vida de Mar\u00eda",
    timeline_subtitle: "Un mes entero. Desaf\u00edos reales. Victorias que lo cambian todo. Sigue cada paso.",
    timeline_day1_title: "\u201CMi dinero se evapora y no s\u00e9 c\u00f3mo\u201D",
    timeline_day1_pain: "María se sienta, nerviosa, con un montón de extractos y recibos. Cada vez que intenta entender cuánto puede gastar, acaba confusa e incómoda.",
    timeline_day1_resolution: "Con la app, en 5-10 minutos, introduce sus ingresos y gastos principales. La app le muestra el mes entero antes de empezar a gastar — cuánto entra, cuánto sale y dónde suele evaporarse el dinero. Por primera vez en mucho tiempo, siente que tiene su vida financiera bajo control.",
    timeline_day5_title: "\u201CSe acabaron las multas. Se acab\u00f3 el p\u00e1nico.\u201D",
    timeline_day5_pain: "Cada vez que se acerca la fecha de una factura, María siente ese nudo en el estómago: miedo a multas, a fallar, a penalizaciones. El estrés crea una ansiedad constante.",
    timeline_day5_resolution: "La app envía un recordatorio anticipado para la factura del gas que vence mañana. María paga a tiempo, sin nervios, sin miedo. Una pequeña alerta hace que el estrés desaparezca.",
    timeline_day9_title: "\u201CEl caos de las comidas se acab\u00f3 de una vez\u201D",
    timeline_day9_pain: "La verdad es que decidir comidas todos los días acaba siempre convirtiéndose en una batalla: o decides por impulso, o acabas gastando más en la tienda con esa sensación de culpa.",
    timeline_day9_resolution: "El plan de comidas semanal está listo. La lista de compras se genera automáticamente según el presupuesto que definió. Entrar al supermercado deja de ser un momento tenso — es ahora una experiencia clara, organizada y sin decisiones impulsivas.",
    timeline_day14_title: "\u201CMediado el mes y el presupuesto se derrumba\u201D",
    timeline_day14_pain: "Ha pasado la mitad del mes y María ve que gran parte del presupuesto se fue en restaurantes. Eso trae culpa, inseguridad y esa sensación de 'no alcanza'.",
    timeline_day14_resolution: "La app muestra una alerta de ritmo de gastos y explica claramente el impacto en el presupuesto. María y João deciden cocinar más en casa este fin de semana — no por obligación, sino porque sienten que vuelven a estar al mando de sus decisiones.",
    timeline_day18_title: "\u201CEntrar al supermercado sin miedo — por fin\u201D",
    timeline_day18_pain: "Antes, María entraba al supermercado sin saber exactamente cuánto iba a gastar — y eso generaba ansiedad, miedo de superar el presupuesto y decisiones impulsivas en el carrito.",
    timeline_day18_resolution: "Hoy, María abre la app y ve una lista de compras construida con los productos que planificó para las comidas, con los precios medios que la app guarda. En vez de adivinar, ve un valor estimado total para su compra antes de salir de casa.",
    timeline_day25_title: "\u201CAlquiler, matr\u00edculas, seguro — todo cubierto. Respira.\u201D",
    timeline_day25_pain: "La ansiedad de final de mes es real y poderosa: \u201C¿Y si falta para el alquiler? ¿Para las matrículas? ¿Para el seguro?\u201D",
    timeline_day25_resolution: "El dashboard muestra cuánto queda en cada categoría. María ve que aún tiene €120 para educación, y eso trae una tranquilidad que no sentía desde hacía años. Ya no es adivinación — es confianza respaldada por datos.",
    timeline_day30_title: "\u201C\u20AC180 ahorrados — sin sacrificio, sin culpa\u201D",
    timeline_day30_pain: "En el pasado, acabar el mes con algo de dinero parecía imposible. Siempre había un aprieto, un estrés final.",
    timeline_day30_resolution: "Ahora María ve €180 ahorrados. La app muestra una racha de hábitos saludables y da sugerencias para reforzar un fondo de emergencia. Por primera vez, ahorrar no fue un sacrificio — fue algo que ocurrió sin que tuviera que castigarse por ello.",
    privacy_title: "Política de Privacidad",
    privacy_last_updated: "Última actualización: 3 de marzo de 2026",
    terms_title: "Términos de Uso",
    terms_last_updated: "Última actualización: 3 de marzo de 2026",
  },

  fr: {
    skip_link: "Aller au contenu",
    nav_home: "Accueil",
    nav_features: "Fonctionnalités",
    nav_screens: "Écrans",
    nav_privacy: "Confidentialité",
    nav_terms: "Conditions",
    nav_usecases: "Cas d'Usage",
    nav_theme_aria: "Basculer le mode sombre",
    nav_lang_aria: "Langue",
    hero_badge: "100% gratuite sur Android — sans pi\u00e8ge",
    hero_title_line1: "Votre argent a cess\u00e9",
    hero_title_line2: "de vous emp\u00eacher de dormir",
    hero_subtitle: "Des milliers de familles contr\u00f4lent d\u00e9j\u00e0 leurs imp\u00f4ts, courses et chaque centime du mois. Rejoignez-les avec l\u2019app gratuite qui change tout.",
    hero_cta_primary: "T\u00e9l\u00e9charger Gratuitement",
    hero_cta_secondary: "D\u00e9couvrez Comment \u00c7a Marche",
    stat_features_label: "Fonctionnalités",
    stat_screens_label: "Écrans",
    stat_languages_label: "Langues",
    stat_free_label: "Gratuite",
    mockup_title: "Budget Mensuel",
    mockup_net_label: "Revenu Net",
    mockup_expenses_label: "Dépenses",
    mockup_savings_label: "Épargne",
    mockup_trend_label: "Tendance Mensuelle",
    mockup_label: "Dashboard",
    float1: "+\u20AC619 \u00e9conomis\u00e9s ce mois !",
    float2: "D\u00e9penses 100% ma\u00eetris\u00e9es",
    float3: "Budget blind\u00e9 et s\u00e9curis\u00e9",
    trust1: "Vos donn\u00e9es restent sur votre t\u00e9l\u00e9phone",
    trust2: "Z\u00e9ro pub. Pour toujours.",
    trust3: "100% gratuite \u2014 aucun co\u00fbt cach\u00e9",
    trust4: "Vie priv\u00e9e prot\u00e9g\u00e9e par le RGPD",
    features_title: "Arr\u00eatez de survivre au mois. Dominez-le.",
    features_desc: "Chaque fonctionnalit\u00e9 a \u00e9t\u00e9 cr\u00e9\u00e9e pour \u00e9liminer un probl\u00e8me r\u00e9el qui vous a d\u00e9j\u00e0 emp\u00each\u00e9 de dormir.",
    feat1_title: "Un Budget Qui Travaille Pour Vous",
    feat1_desc: "Voyez o\u00f9 va chaque euro avant de le d\u00e9penser. Revenus, d\u00e9penses et cat\u00e9gories au centime pr\u00e8s \u2014 fini les mauvaises surprises en fin de mois.",
    feat2_title: "Imp\u00f4ts Calcul\u00e9s au Centime",
    feat2_desc: "Oubliez les tableurs et les simulateurs douteux. Tables IRS portugaises int\u00e9gr\u00e9es \u2014 voyez votre revenu net r\u00e9el instantan\u00e9ment.",
    feat3_title: "Courses Sans Mauvaise Surprise en Caisse",
    feat3_desc: "Entrez au supermarch\u00e9 avec une liste et des prix r\u00e9els. Connaissez le total avant de partir \u2014 fini l\u2019anxi\u00e9t\u00e9 dans les rayons.",
    feat4_title: "Toute la Famille sur la M\u00eame Page",
    feat4_desc: "Partagez le budget avec ceux qui vivent avec vous. Les d\u00e9cisions financi\u00e8res cessent d\u2019\u00eatre une guerre et deviennent un travail d\u2019\u00e9quipe.",
    feat5_title: "Repas Planifi\u00e9s, Portefeuille Prot\u00e9g\u00e9",
    feat5_desc: "30 jours de repas qui respectent votre budget. Ingr\u00e9dients regroup\u00e9s, co\u00fbts calcul\u00e9s \u2014 fini l\u2019improvisation qui fait exploser la note.",
    feat6_title: "Un Coach Financier Qui Vous Conna\u00eet",
    feat6_desc: "Conseils personnalis\u00e9s bas\u00e9s sur vos habitudes r\u00e9elles. L\u2019IA analyse vos sch\u00e9mas et vous aide \u00e0 \u00e9pargner sans renoncer \u00e0 ce que vous aimez.",
    screens_title: "5 \u00e9crans. Z\u00e9ro confusion. Contr\u00f4le absolu.",
    screens_desc: "Chaque \u00e9cran vous donne des r\u00e9ponses en secondes \u2014 pas plus de questions.",
    screen1_title: "Tableau de bord",
    screen1_desc: "Ouvrez l\u2019app et voyez en un instant si votre mois est dans le vert ou le rouge.",
    screen2_title: "Supermarch\u00e9",
    screen2_desc: "Prix r\u00e9els des produits que vous achetez \u2014 comparez et \u00e9conomisez sans effort.",
    screen3_title: "Liste de Courses",
    screen3_desc: "Partag\u00e9e en famille et mise \u00e0 jour en temps r\u00e9el \u2014 personne n\u2019ach\u00e8te en trop.",
    screen4_title: "Repas",
    screen4_desc: "Fini l\u2019\u00e9ternel \u00ab on mange quoi ? \u00bb \u2014 le planning hebdo d\u00e9cide pour vous.",
    screen5_title: "Coach IA",
    screen5_desc: "Votre conseiller financier de poche, disponible 24h sur 24.",
    cta_title: "Le mois prochain peut \u00eatre diff\u00e9rent. Commencez aujourd\u2019hui.",
    cta_desc: "Des familles partout dans le pays ont d\u00e9j\u00e0 repris le contr\u00f4le. Gratuite, sans pubs, faite au Portugal pour vous.",
    cta_button: "T\u00e9l\u00e9charger Gratuitement",
    footer_desc: "L\u2019app qui transforme la fa\u00e7on dont les familles vivent l\u2019argent.",
    footer_app_heading: "App",
    footer_legal_heading: "Légal",
    footer_feat_link: "Fonctionnalités",
    footer_screens_link: "Écrans",
    footer_download_link: "Télécharger",
    footer_privacy_link: "Politique de Confidentialité",
    footer_terms_link: "Conditions d'Utilisation",
    footer_copyright: "© 2026 Gestão Mensal. Tous droits réservés.",
    footer_made_in: "Fait avec soin au Portugal",
    timeline_title: "30 jours qui ont boulevers\u00e9 la vie de Maria",
    timeline_subtitle: "Un mois entier. Des d\u00e9fis r\u00e9els. Des victoires qui changent tout. Suivez chaque \u00e9tape.",
    timeline_day1_title: "\u201CMon argent s\u2019\u00e9vapore et je ne sais m\u00eame plus comment\u201D",
    timeline_day1_pain: "Maria s'assoit, nerveuse, avec une pile de relevés et de reçus. À chaque fois qu'elle essaie de comprendre combien elle peut dépenser, elle finit confuse et mal à l'aise.",
    timeline_day1_resolution: "Avec l'app, en 5-10 minutes, elle saisit ses revenus et dépenses principales. L'app lui montre le mois entier avant qu'elle ne commence à dépenser — combien entre, combien sort, et où l'argent s'évapore habituellement. Pour la première fois depuis longtemps, elle sent que sa vie financière est sous contrôle.",
    timeline_day5_title: "\u201CFini les amendes. Fini la panique.\u201D",
    timeline_day5_pain: "À chaque fois qu'une échéance approche, Maria ressent ce nœud à l'estomac : peur des amendes, de l'échec, des pénalités. Le stress crée une anxiété constante.",
    timeline_day5_resolution: "L'app envoie un rappel anticipé pour la facture de gaz qui expire demain. Maria paie à temps, sans nerfs, sans peur. Une petite alerte fait disparaître le stress.",
    timeline_day9_title: "\u201CLe chaos des repas, c\u2019est termin\u00e9 pour de bon\u201D",
    timeline_day9_pain: "La vérité, c'est que décider des repas tous les jours finit toujours par devenir une bataille : soit on décide par impulsion, soit on finit par dépenser plus au magasin avec cette sensation de culpabilité.",
    timeline_day9_resolution: "Le plan de repas hebdomadaire est prêt. La liste de courses est générée automatiquement selon le budget qu'elle a défini. Aller au supermarché cesse d'être un moment tendu — c'est désormais une expérience claire, organisée et sans décisions impulsives.",
    timeline_day14_title: "\u201CMi-mois et le budget d\u00e9rape\u201D",
    timeline_day14_pain: "La moitié du mois est passée et Maria voit qu'une grande partie du budget est partie en restaurants. Cela apporte culpabilité, insécurité et cette sensation que « ça ne suffit pas ».",
    timeline_day14_resolution: "L'app affiche une alerte de rythme de dépenses et explique clairement l'impact sur le budget. Maria et João décident de cuisiner davantage à la maison ce week-end — non par obligation, mais parce qu'ils sentent qu'ils reprennent le contrôle de leurs choix.",
    timeline_day18_title: "\u201CEntrer au supermarch\u00e9 sans peur \u2014 enfin\u201D",
    timeline_day18_pain: "Avant, Maria entrait au supermarché sans savoir exactement combien elle allait dépenser — et cela générait de l'anxiété, la peur de dépasser le budget et des décisions impulsives dans le chariot.",
    timeline_day18_resolution: "Aujourd'hui, Maria ouvre l'app et voit une liste de courses construite avec les produits qu'elle a planifiés pour les repas, avec les prix moyens que l'app conserve. Au lieu de deviner, elle voit un total estimé pour ses courses avant de quitter la maison.",
    timeline_day25_title: "\u201CLoyer, frais de scolarit\u00e9, assurance \u2014 tout pay\u00e9. Respirez.\u201D",
    timeline_day25_pain: "L'anxiété de fin de mois est réelle et puissante : « Et s'il manque pour le loyer ? Pour les frais de scolarité ? Pour l'assurance ? »",
    timeline_day25_resolution: "Le tableau de bord montre combien il reste dans chaque catégorie. Maria voit qu'elle a encore 120€ pour l'éducation, et cela apporte une tranquillité d'esprit qu'elle n'avait pas ressentie depuis des années. Ce n'est plus de la devinette — c'est de la confiance appuyée par les données.",
    timeline_day30_title: "\u201C180\u20AC \u00e9conomis\u00e9s \u2014 sans sacrifice, sans culpabilit\u00e9\u201D",
    timeline_day30_pain: "Par le passé, finir le mois avec de l'argent semblait impossible. Il y avait toujours un serrement, un stress final.",
    timeline_day30_resolution: "Maintenant Maria voit 180€ économisés. L'app montre une série d'habitudes saines et donne des suggestions pour renforcer un fonds d'urgence. Pour la première fois, épargner n'a pas été un sacrifice — c'est arrivé sans qu'elle ait à se punir pour cela.",
    privacy_title: "Politique de Confidentialité",
    privacy_last_updated: "Dernière mise à jour : 3 mars 2026",
    terms_title: "Conditions d'Utilisation",
    terms_last_updated: "Dernière mise à jour : 3 mars 2026",
  },
};
