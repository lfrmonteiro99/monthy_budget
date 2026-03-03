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
    hero_badge: "Disponível para Android",
    hero_title_line1: "O seu orçamento mensal,",
    hero_title_line2: "simples e inteligente",
    hero_subtitle: "Planeie, controle e otimize as finanças da sua família. Com cálculo automático de IRS, planeamento de refeições e coach financeiro com IA.",
    hero_cta_primary: "Disponível na Google Play",
    hero_cta_secondary: "Saber Mais",
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
    float1: "Poupança: +€619",
    float2: "Despesas no limite",
    float3: "Orçamento seguro",
    trust1: "Dados no dispositivo",
    trust2: "Sem anúncios",
    trust3: "100% gratuita",
    trust4: "RGPD compliant",
    features_title: "Tudo o que precisa num só lugar",
    features_desc: "Funcionalidades desenhadas para simplificar a gestão financeira da sua família.",
    feat1_title: "Orçamento Inteligente",
    feat1_desc: "Planeie receitas e despesas mensais com categorias personalizáveis. Acompanhe despesas reais vs. planeadas em tempo real.",
    feat2_title: "Cálculo de IRS Automático",
    feat2_desc: "Tabelas de IRS portuguesas integradas. Saiba exatamente o rendimento líquido mensal com base no seu escalão.",
    feat3_title: "Lista de Compras",
    feat3_desc: "Crie e gira listas de compras com preços reais do supermercado. Sincronização em tempo real entre dispositivos.",
    feat4_title: "Gestão Familiar",
    feat4_desc: "Partilhe o orçamento com o agregado familiar. Cada membro pode contribuir e visualizar as finanças do lar.",
    feat5_title: "Planeamento de Refeições",
    feat5_desc: "Planeie 30 dias de refeições dentro do orçamento alimentar. Receitas otimizadas com ingredientes agrupados e custos calculados.",
    feat6_title: "Coach Financeiro com IA",
    feat6_desc: "Receba conselhos financeiros personalizados baseados nos seus padrões de despesa. Análise inteligente das suas finanças.",
    screens_title: "5 Ecrãs, controlo total",
    screens_desc: "Cada ecrã foi desenhado para tornar a gestão financeira simples e intuitiva.",
    screen1_title: "Dashboard",
    screen1_desc: "Visão geral do orçamento, tendências e metas de poupança.",
    screen2_title: "Supermercado",
    screen2_desc: "Catálogo de produtos com preços e favoritos.",
    screen3_title: "Lista de Compras",
    screen3_desc: "Listas partilhadas com sincronização em tempo real.",
    screen4_title: "Refeições",
    screen4_desc: "Planeie refeições semanais dentro do orçamento alimentar.",
    screen5_title: "Coach IA",
    screen5_desc: "Conselhos financeiros inteligentes e personalizados.",
    cta_title: "Tome o controlo das suas finanças",
    cta_desc: "Descarregue a Gestão Mensal e comece a poupar com a app mais completa para famílias portuguesas.",
    cta_button: "Disponível na Google Play",
    footer_desc: "A app de orçamento mensal mais completa para famílias portuguesas.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Funcionalidades",
    footer_screens_link: "Ecrãs",
    footer_download_link: "Descarregar",
    footer_privacy_link: "Política de Privacidade",
    footer_terms_link: "Termos de Utilização",
    footer_copyright: "© 2026 Gestão Mensal. Todos os direitos reservados.",
    footer_made_in: "Feito com cuidado em Portugal",
    timeline_title: "Como a Maria gere o mês",
    timeline_subtitle: "Acompanhe a Maria durante um mês inteiro. Cada dia traz um desafio real — e uma solução concreta.",
    timeline_day1_title: "\u201CJá nem sei para onde é que o meu dinheiro vai\u201D",
    timeline_day1_pain: "Maria senta-se, nervosa, com uma pilha de extratos e recibos. Sempre que tenta perceber quanto pode gastar, acaba confusa e desconfortável.",
    timeline_day1_resolution: "Com a app, em 5-10 minutos, ela introduz os seus rendimentos e despesas principais. A app mostra-lhe o mês inteiro antes de começar a gastar — quanto entra, quanto sai, e onde normalmente o dinheiro evapora. Pela primeira vez em muito tempo, ela sente que tem a sua vida financeira sob controlo.",
    timeline_day5_title: "\u201CJá me esquecia da conta outra vez…\u201D",
    timeline_day5_pain: "Sempre que se aproxima a data de uma conta, Maria sente aquele apertar no estômago: medo de multas, de falhar, de penalizações. O stress cria uma ansiedade constante.",
    timeline_day5_resolution: "A app envia um lembrete antecipado para a conta do gás que vence amanhã. Maria paga a tempo, sem nervos, sem medo. Um pequeno alerta faz com que o stress desapareça.",
    timeline_day9_title: "\u201CE agora o que é que vamos cozinhar?\u201D",
    timeline_day9_pain: "A verdade é que decidir refeições todos os dias acaba sempre por se tornar uma batalha: ou te decides por impulso, ou acabas por gastar mais na loja e tens aquela sensação de culpa.",
    timeline_day9_resolution: "O plano de refeições semanal está pronto. A lista de compras é gerada automaticamente com base no orçamento que ela definiu. Entrar no supermercado deixa de ser um momento tenso — é agora uma experiência clara, organizada e sem decisões impulsivas.",
    timeline_day14_title: "\u201CJá tenho demasiado gasto fora…\u201D",
    timeline_day14_pain: "Metade do mês passou e Maria vê que uma grande parte do orçamento foi gasta em restaurantes. Isso traz culpa, insegurança e aquela sensação de 'não chega'. Em termos comportamentais, isto é comum — stress pode levar a decisões de gasto impulsivas quando não há estrutura.",
    timeline_day14_resolution: "A app mostra um aviso de ritmo de gastos e explica claramente o impacto no orçamento. Maria e João decidem cozinhar mais em casa este fim de semana — não por obrigação, mas por sentirem que estão novamente no comando das suas escolhas.",
    timeline_day18_title: "\u201CIr ao supermercado sinto-me sempre a adivinhar quanto vou gastar\u201D",
    timeline_day18_pain: "Antes, Maria entrava no supermercado sem saber ao certo quanto iria gastar — e isso gerava ansiedade, medo de ultrapassar o orçamento e decisões impulsivas no carrinho. Estudos mostram que uma lista bem planeada ajuda a reduzir despesa e desperdício simplesmente ao focar a compra no que é realmente necessário.",
    timeline_day18_resolution: "Hoje, Maria abre a app e vê uma lista de compras construída com os produtos que planeou para as refeições, com os preços médios associados que a app guarda com base nos dados que o próprio utilizador introduziu ou consultou ao longo do tempo. Em vez de adivinhar, ela vê um valor estimado total para a sua compra antes de sair de casa. Ao construir a lista, Maria sabe exatamente quanto costuma valer cada item e como isso soma ao total previsto da compra. Entrar no supermercado deixa de ser um salto no escuro e passa a ser uma tarefa consciente: ela vê o impacto estimado no orçamento e toma decisões no carrinho com confiança, reduzindo stress e ajudando-a a manter o plano financeiro que definiu no início do mês.",
    timeline_day25_title: "\u201CSerá que ainda consigo pagar as despesas grandes este mês?\u201D",
    timeline_day25_pain: "A ansiedade baixa no final do mês é real e poderosa: \u201CE se faltar dinheiro para a renda? Para as propinas? Para o seguro?\u201D",
    timeline_day25_resolution: "O dashboard mostra quanto resta em cada categoria. Maria vê que ainda tem €120 para educação, e isso traz uma paz de espírito que ela não sentia há anos. Já não é adivinhação — é confiança apoiada nos dados.",
    timeline_day30_title: "\u201CFinalmente sobra algum dinheiro…\u201D",
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
    hero_badge: "Available on Android",
    hero_title_line1: "Your monthly budget,",
    hero_title_line2: "simple and smart",
    hero_subtitle: "Plan, track and optimise your family finances. With automatic tax calculation, meal planning and an AI financial coach.",
    hero_cta_primary: "Available on Google Play",
    hero_cta_secondary: "Learn More",
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
    float1: "Savings: +€619",
    float2: "Expenses on track",
    float3: "Budget secure",
    trust1: "Data on device",
    trust2: "No ads",
    trust3: "100% free",
    trust4: "GDPR compliant",
    features_title: "Everything you need in one place",
    features_desc: "Features designed to simplify your family's financial management.",
    feat1_title: "Smart Budgeting",
    feat1_desc: "Plan monthly income and expenses with customisable categories. Track actual vs. planned spending in real time.",
    feat2_title: "Automatic Tax Calculation",
    feat2_desc: "Portuguese IRS tax tables built in. Know your exact monthly net income based on your tax bracket.",
    feat3_title: "Shopping List",
    feat3_desc: "Create and manage shopping lists with real supermarket prices. Real-time synchronisation across devices.",
    feat4_title: "Family Management",
    feat4_desc: "Share the budget with your household. Each member can contribute and view the family finances.",
    feat5_title: "Meal Planning",
    feat5_desc: "Plan 30 days of meals within your food budget. Optimised recipes with grouped ingredients and calculated costs.",
    feat6_title: "AI Financial Coach",
    feat6_desc: "Receive personalised financial advice based on your spending patterns. Intelligent analysis of your finances.",
    screens_title: "5 Screens, total control",
    screens_desc: "Each screen was designed to make financial management simple and intuitive.",
    screen1_title: "Dashboard",
    screen1_desc: "Budget overview, trends and savings goals.",
    screen2_title: "Supermarket",
    screen2_desc: "Product catalogue with prices and favourites.",
    screen3_title: "Shopping List",
    screen3_desc: "Shared lists with real-time synchronisation.",
    screen4_title: "Meals",
    screen4_desc: "Plan weekly meals within your food budget.",
    screen5_title: "AI Coach",
    screen5_desc: "Smart and personalised financial advice.",
    cta_title: "Take control of your finances",
    cta_desc: "Download Gestão Mensal and start saving with the most complete app for families.",
    cta_button: "Available on Google Play",
    footer_desc: "The most complete monthly budget app for families.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Features",
    footer_screens_link: "Screens",
    footer_download_link: "Download",
    footer_privacy_link: "Privacy Policy",
    footer_terms_link: "Terms of Use",
    footer_copyright: "© 2026 Gestão Mensal. All rights reserved.",
    footer_made_in: "Made with care in Portugal",
    timeline_title: "How Maria manages her month",
    timeline_subtitle: "Follow Maria through an entire month. Each day brings a real challenge — and a concrete solution.",
    timeline_day1_title: "\u201CI don\u2019t even know where my money goes anymore\u201D",
    timeline_day1_pain: "Maria sits down, anxious, with a pile of statements and receipts. Every time she tries to figure out how much she can spend, she ends up confused and uncomfortable.",
    timeline_day1_resolution: "With the app, in 5-10 minutes, she enters her income and main expenses. The app shows her the entire month before she starts spending — how much comes in, how much goes out, and where money usually evaporates. For the first time in a long while, she feels her financial life is under control.",
    timeline_day5_title: "\u201CI almost forgot about the bill again…\u201D",
    timeline_day5_pain: "Every time a bill due date approaches, Maria feels that knot in her stomach: fear of fines, of failing, of penalties. The stress creates constant anxiety.",
    timeline_day5_resolution: "The app sends an early reminder for the gas bill due tomorrow. Maria pays on time, without nerves, without fear. A small alert makes the stress disappear.",
    timeline_day9_title: "\u201CSo what are we cooking tonight?\u201D",
    timeline_day9_pain: "The truth is that deciding meals every day always ends up becoming a battle: either you decide on impulse, or you end up spending more at the store with that feeling of guilt.",
    timeline_day9_resolution: "The weekly meal plan is ready. The shopping list is automatically generated based on the budget she set. Going to the supermarket stops being a tense moment — it\u2019s now a clear, organized experience without impulsive decisions.",
    timeline_day14_title: "\u201CI\u2019ve already spent too much eating out…\u201D",
    timeline_day14_pain: "Half the month has passed and Maria sees that a large portion of the budget was spent on restaurants. This brings guilt, insecurity, and that feeling of \u2018it\u2019s not enough\u2019. Behaviorally, this is common — stress can lead to impulsive spending decisions when there\u2019s no structure.",
    timeline_day14_resolution: "The app shows a spending pace alert and clearly explains the impact on the budget. Maria and João decide to cook more at home this weekend — not out of obligation, but because they feel they\u2019re back in control of their choices.",
    timeline_day18_title: "\u201CGoing to the supermarket, I always feel like I\u2019m guessing how much I\u2019ll spend\u201D",
    timeline_day18_pain: "Before, Maria would enter the supermarket without knowing exactly how much she would spend — and that generated anxiety, fear of exceeding the budget, and impulsive decisions at the cart. Studies show that a well-planned list helps reduce spending and waste simply by focusing the purchase on what\u2019s truly needed.",
    timeline_day18_resolution: "Today, Maria opens the app and sees a shopping list built with the products she planned for meals, with average prices the app stores based on data the user entered or consulted over time. Instead of guessing, she sees an estimated total for her purchase before leaving home.",
    timeline_day25_title: "\u201CCan I still afford the big expenses this month?\u201D",
    timeline_day25_pain: "End-of-month anxiety is real and powerful: \u201CWhat if there\u2019s not enough for rent? For tuition? For insurance?\u201D",
    timeline_day25_resolution: "The dashboard shows how much remains in each category. Maria sees she still has €120 for education, and that brings a peace of mind she hadn\u2019t felt in years. It\u2019s no longer guesswork — it\u2019s confidence backed by data.",
    timeline_day30_title: "\u201CFinally, there\u2019s some money left over…\u201D",
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
    hero_badge: "Disponible en Android",
    hero_title_line1: "Tu presupuesto mensual,",
    hero_title_line2: "simple e inteligente",
    hero_subtitle: "Planifica, controla y optimiza las finanzas de tu familia. Con cálculo automático de impuestos, planificación de comidas y coach financiero con IA.",
    hero_cta_primary: "Disponible en Google Play",
    hero_cta_secondary: "Saber más",
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
    float1: "Ahorros: +€619",
    float2: "Gastos bajo control",
    float3: "Presupuesto seguro",
    trust1: "Datos en el dispositivo",
    trust2: "Sin anuncios",
    trust3: "100% gratuita",
    trust4: "RGPD compliant",
    features_title: "Todo lo que necesitas en un solo lugar",
    features_desc: "Funcionalidades diseñadas para simplificar la gestión financiera de tu familia.",
    feat1_title: "Presupuesto Inteligente",
    feat1_desc: "Planifica ingresos y gastos mensuales con categorías personalizables. Controla gastos reales vs. planificados en tiempo real.",
    feat2_title: "Cálculo de Impuestos Automático",
    feat2_desc: "Tablas de IRS portuguesas integradas. Conoce exactamente tu ingreso neto mensual según tu tramo.",
    feat3_title: "Lista de la Compra",
    feat3_desc: "Crea y gestiona listas de la compra con precios reales del supermercado. Sincronización en tiempo real entre dispositivos.",
    feat4_title: "Gestión Familiar",
    feat4_desc: "Comparte el presupuesto con tu hogar. Cada miembro puede contribuir y ver las finanzas del hogar.",
    feat5_title: "Planificación de Comidas",
    feat5_desc: "Planifica 30 días de comidas dentro de tu presupuesto alimentario. Recetas optimizadas con ingredientes agrupados y costes calculados.",
    feat6_title: "Coach Financiero con IA",
    feat6_desc: "Recibe consejos financieros personalizados basados en tus patrones de gasto. Análisis inteligente de tus finanzas.",
    screens_title: "5 Pantallas, control total",
    screens_desc: "Cada pantalla fue diseñada para hacer la gestión financiera simple e intuitiva.",
    screen1_title: "Dashboard",
    screen1_desc: "Visión general del presupuesto, tendencias y metas de ahorro.",
    screen2_title: "Supermercado",
    screen2_desc: "Catálogo de productos con precios y favoritos.",
    screen3_title: "Lista de la Compra",
    screen3_desc: "Listas compartidas con sincronización en tiempo real.",
    screen4_title: "Comidas",
    screen4_desc: "Planifica comidas semanales dentro del presupuesto alimentario.",
    screen5_title: "Coach IA",
    screen5_desc: "Consejos financieros inteligentes y personalizados.",
    cta_title: "Toma el control de tus finanzas",
    cta_desc: "Descarga Gestão Mensal y empieza a ahorrar con la app más completa para familias.",
    cta_button: "Disponible en Google Play",
    footer_desc: "La app de presupuesto mensual más completa para familias.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Funcionalidades",
    footer_screens_link: "Pantallas",
    footer_download_link: "Descargar",
    footer_privacy_link: "Política de Privacidad",
    footer_terms_link: "Términos de Uso",
    footer_copyright: "© 2026 Gestão Mensal. Todos los derechos reservados.",
    footer_made_in: "Hecho con cuidado en Portugal",
    timeline_title: "Cómo María gestiona su mes",
    timeline_subtitle: "Acompaña a María durante un mes entero. Cada día trae un desafío real — y una solución concreta.",
    timeline_day1_title: "\u201CYa ni sé a dónde va mi dinero\u201D",
    timeline_day1_pain: "María se sienta, nerviosa, con un montón de extractos y recibos. Cada vez que intenta entender cuánto puede gastar, acaba confusa e incómoda.",
    timeline_day1_resolution: "Con la app, en 5-10 minutos, introduce sus ingresos y gastos principales. La app le muestra el mes entero antes de empezar a gastar — cuánto entra, cuánto sale y dónde suele evaporarse el dinero. Por primera vez en mucho tiempo, siente que tiene su vida financiera bajo control.",
    timeline_day5_title: "\u201CCasi se me olvida otra vez la factura…\u201D",
    timeline_day5_pain: "Cada vez que se acerca la fecha de una factura, María siente ese nudo en el estómago: miedo a multas, a fallar, a penalizaciones. El estrés crea una ansiedad constante.",
    timeline_day5_resolution: "La app envía un recordatorio anticipado para la factura del gas que vence mañana. María paga a tiempo, sin nervios, sin miedo. Una pequeña alerta hace que el estrés desaparezca.",
    timeline_day9_title: "\u201C¿Y ahora qué cenamos?\u201D",
    timeline_day9_pain: "La verdad es que decidir comidas todos los días acaba siempre convirtiéndose en una batalla: o decides por impulso, o acabas gastando más en la tienda con esa sensación de culpa.",
    timeline_day9_resolution: "El plan de comidas semanal está listo. La lista de compras se genera automáticamente según el presupuesto que definió. Entrar al supermercado deja de ser un momento tenso — es ahora una experiencia clara, organizada y sin decisiones impulsivas.",
    timeline_day14_title: "\u201CYa he gastado demasiado comiendo fuera…\u201D",
    timeline_day14_pain: "Ha pasado la mitad del mes y María ve que gran parte del presupuesto se fue en restaurantes. Eso trae culpa, inseguridad y esa sensación de 'no alcanza'.",
    timeline_day14_resolution: "La app muestra una alerta de ritmo de gastos y explica claramente el impacto en el presupuesto. María y João deciden cocinar más en casa este fin de semana — no por obligación, sino porque sienten que vuelven a estar al mando de sus decisiones.",
    timeline_day18_title: "\u201CIr al supermercado siempre siento que estoy adivinando cuánto voy a gastar\u201D",
    timeline_day18_pain: "Antes, María entraba al supermercado sin saber exactamente cuánto iba a gastar — y eso generaba ansiedad, miedo de superar el presupuesto y decisiones impulsivas en el carrito.",
    timeline_day18_resolution: "Hoy, María abre la app y ve una lista de compras construida con los productos que planificó para las comidas, con los precios medios que la app guarda. En vez de adivinar, ve un valor estimado total para su compra antes de salir de casa.",
    timeline_day25_title: "\u201C¿Podré pagar los gastos grandes este mes?\u201D",
    timeline_day25_pain: "La ansiedad de final de mes es real y poderosa: \u201C¿Y si falta para el alquiler? ¿Para las matrículas? ¿Para el seguro?\u201D",
    timeline_day25_resolution: "El dashboard muestra cuánto queda en cada categoría. María ve que aún tiene €120 para educación, y eso trae una tranquilidad que no sentía desde hacía años. Ya no es adivinación — es confianza respaldada por datos.",
    timeline_day30_title: "\u201CPor fin sobra algo de dinero…\u201D",
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
    hero_badge: "Disponible sur Android",
    hero_title_line1: "Votre budget mensuel,",
    hero_title_line2: "simple et intelligent",
    hero_subtitle: "Planifiez, contrôlez et optimisez les finances de votre famille. Avec calcul automatique des impôts, planification des repas et coach financier IA.",
    hero_cta_primary: "Disponible sur Google Play",
    hero_cta_secondary: "En savoir plus",
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
    float1: "Épargne : +€619",
    float2: "Dépenses maîtrisées",
    float3: "Budget sécurisé",
    trust1: "Données sur l'appareil",
    trust2: "Sans publicités",
    trust3: "100% gratuite",
    trust4: "Conforme RGPD",
    features_title: "Tout ce dont vous avez besoin en un seul endroit",
    features_desc: "Des fonctionnalités conçues pour simplifier la gestion financière de votre famille.",
    feat1_title: "Budget Intelligent",
    feat1_desc: "Planifiez vos revenus et dépenses mensuels avec des catégories personnalisables. Suivez les dépenses réelles vs. planifiées en temps réel.",
    feat2_title: "Calcul d'Impôts Automatique",
    feat2_desc: "Tables IRS portugaises intégrées. Connaissez exactement votre revenu net mensuel selon votre tranche d'imposition.",
    feat3_title: "Liste de Courses",
    feat3_desc: "Créez et gérez des listes de courses avec les prix réels du supermarché. Synchronisation en temps réel entre appareils.",
    feat4_title: "Gestion Familiale",
    feat4_desc: "Partagez le budget avec votre foyer. Chaque membre peut contribuer et consulter les finances du ménage.",
    feat5_title: "Planification des Repas",
    feat5_desc: "Planifiez 30 jours de repas dans le cadre de votre budget alimentaire. Recettes optimisées avec ingrédients regroupés et coûts calculés.",
    feat6_title: "Coach Financier IA",
    feat6_desc: "Recevez des conseils financiers personnalisés basés sur vos habitudes de dépense. Analyse intelligente de vos finances.",
    screens_title: "5 Écrans, contrôle total",
    screens_desc: "Chaque écran a été conçu pour rendre la gestion financière simple et intuitive.",
    screen1_title: "Tableau de bord",
    screen1_desc: "Vue d'ensemble du budget, tendances et objectifs d'épargne.",
    screen2_title: "Supermarché",
    screen2_desc: "Catalogue de produits avec prix et favoris.",
    screen3_title: "Liste de Courses",
    screen3_desc: "Listes partagées avec synchronisation en temps réel.",
    screen4_title: "Repas",
    screen4_desc: "Planifiez les repas hebdomadaires dans le budget alimentaire.",
    screen5_title: "Coach IA",
    screen5_desc: "Conseils financiers intelligents et personnalisés.",
    cta_title: "Prenez le contrôle de vos finances",
    cta_desc: "Téléchargez Gestão Mensal et commencez à économiser avec l'app la plus complète pour les familles.",
    cta_button: "Disponible sur Google Play",
    footer_desc: "L'app de budget mensuel la plus complète pour les familles.",
    footer_app_heading: "App",
    footer_legal_heading: "Légal",
    footer_feat_link: "Fonctionnalités",
    footer_screens_link: "Écrans",
    footer_download_link: "Télécharger",
    footer_privacy_link: "Politique de Confidentialité",
    footer_terms_link: "Conditions d'Utilisation",
    footer_copyright: "© 2026 Gestão Mensal. Tous droits réservés.",
    footer_made_in: "Fait avec soin au Portugal",
    timeline_title: "Comment Maria gère son mois",
    timeline_subtitle: "Suivez Maria pendant un mois entier. Chaque jour apporte un défi réel — et une solution concrète.",
    timeline_day1_title: "\u201CJe ne sais même plus où va mon argent\u201D",
    timeline_day1_pain: "Maria s'assoit, nerveuse, avec une pile de relevés et de reçus. À chaque fois qu'elle essaie de comprendre combien elle peut dépenser, elle finit confuse et mal à l'aise.",
    timeline_day1_resolution: "Avec l'app, en 5-10 minutes, elle saisit ses revenus et dépenses principales. L'app lui montre le mois entier avant qu'elle ne commence à dépenser — combien entre, combien sort, et où l'argent s'évapore habituellement. Pour la première fois depuis longtemps, elle sent que sa vie financière est sous contrôle.",
    timeline_day5_title: "\u201CJ'allais encore oublier la facture…\u201D",
    timeline_day5_pain: "À chaque fois qu'une échéance approche, Maria ressent ce nœud à l'estomac : peur des amendes, de l'échec, des pénalités. Le stress crée une anxiété constante.",
    timeline_day5_resolution: "L'app envoie un rappel anticipé pour la facture de gaz qui expire demain. Maria paie à temps, sans nerfs, sans peur. Une petite alerte fait disparaître le stress.",
    timeline_day9_title: "\u201CEt maintenant, on mange quoi ce soir ?\u201D",
    timeline_day9_pain: "La vérité, c'est que décider des repas tous les jours finit toujours par devenir une bataille : soit on décide par impulsion, soit on finit par dépenser plus au magasin avec cette sensation de culpabilité.",
    timeline_day9_resolution: "Le plan de repas hebdomadaire est prêt. La liste de courses est générée automatiquement selon le budget qu'elle a défini. Aller au supermarché cesse d'être un moment tendu — c'est désormais une expérience claire, organisée et sans décisions impulsives.",
    timeline_day14_title: "\u201CJ'ai déjà trop dépensé au restaurant…\u201D",
    timeline_day14_pain: "La moitié du mois est passée et Maria voit qu'une grande partie du budget est partie en restaurants. Cela apporte culpabilité, insécurité et cette sensation que « ça ne suffit pas ».",
    timeline_day14_resolution: "L'app affiche une alerte de rythme de dépenses et explique clairement l'impact sur le budget. Maria et João décident de cuisiner davantage à la maison ce week-end — non par obligation, mais parce qu'ils sentent qu'ils reprennent le contrôle de leurs choix.",
    timeline_day18_title: "\u201CAu supermarché, j'ai toujours l'impression de deviner combien je vais dépenser\u201D",
    timeline_day18_pain: "Avant, Maria entrait au supermarché sans savoir exactement combien elle allait dépenser — et cela générait de l'anxiété, la peur de dépasser le budget et des décisions impulsives dans le chariot.",
    timeline_day18_resolution: "Aujourd'hui, Maria ouvre l'app et voit une liste de courses construite avec les produits qu'elle a planifiés pour les repas, avec les prix moyens que l'app conserve. Au lieu de deviner, elle voit un total estimé pour ses courses avant de quitter la maison.",
    timeline_day25_title: "\u201CEst-ce que je pourrai encore payer les grosses dépenses ce mois-ci ?\u201D",
    timeline_day25_pain: "L'anxiété de fin de mois est réelle et puissante : « Et s'il manque pour le loyer ? Pour les frais de scolarité ? Pour l'assurance ? »",
    timeline_day25_resolution: "Le tableau de bord montre combien il reste dans chaque catégorie. Maria voit qu'elle a encore 120€ pour l'éducation, et cela apporte une tranquillité d'esprit qu'elle n'avait pas ressentie depuis des années. Ce n'est plus de la devinette — c'est de la confiance appuyée par les données.",
    timeline_day30_title: "\u201CEnfin, il reste de l'argent…\u201D",
    timeline_day30_pain: "Par le passé, finir le mois avec de l'argent semblait impossible. Il y avait toujours un serrement, un stress final.",
    timeline_day30_resolution: "Maintenant Maria voit 180€ économisés. L'app montre une série d'habitudes saines et donne des suggestions pour renforcer un fonds d'urgence. Pour la première fois, épargner n'a pas été un sacrifice — c'est arrivé sans qu'elle ait à se punir pour cela.",
    privacy_title: "Politique de Confidentialité",
    privacy_last_updated: "Dernière mise à jour : 3 mars 2026",
    terms_title: "Conditions d'Utilisation",
    terms_last_updated: "Dernière mise à jour : 3 mars 2026",
  },
};
