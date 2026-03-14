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
  stat1_value: string;
  stat1_label: string;
  stat2_value: string;
  stat2_label: string;
  stat3_value: string;
  stat3_label: string;
  stat4_value: string;
  stat4_label: string;
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
  how_title: string;
  how_desc: string;
  how_step1_title: string;
  how_step1_desc: string;
  how_step2_title: string;
  how_step2_desc: string;
  how_step3_title: string;
  how_step3_desc: string;
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
  cta_micro: string;
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
  timeline_intro: string;
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
  faq_title: string;
  faq1_q: string;
  faq1_a: string;
  faq2_q: string;
  faq2_a: string;
  faq3_q: string;
  faq3_a: string;
  faq4_q: string;
  faq4_a: string;
  faq5_q: string;
  faq5_a: string;
  faq6_q: string;
  faq6_a: string;
  faq7_q: string;
  faq7_a: string;
  faq8_q: string;
  faq8_a: string;
  nav_pricing: string;
  pricing_title: string;
  pricing_desc: string;
  pricing_toggle_monthly: string;
  pricing_toggle_yearly: string;
  pricing_save_badge: string;
  pricing_trial_banner: string;
  pricing_free_name: string;
  pricing_free_price: string;
  pricing_free_period: string;
  pricing_free_desc: string;
  pricing_free_cta: string;
  pricing_free_feat1: string;
  pricing_free_feat2: string;
  pricing_free_feat3: string;
  pricing_free_feat4: string;
  pricing_free_feat5: string;
  pricing_premium_name: string;
  pricing_premium_price_monthly: string;
  pricing_premium_price_yearly: string;
  pricing_premium_period_monthly: string;
  pricing_premium_period_yearly: string;
  pricing_premium_desc: string;
  pricing_premium_cta: string;
  pricing_premium_popular: string;
  pricing_premium_feat1: string;
  pricing_premium_feat2: string;
  pricing_premium_feat3: string;
  pricing_premium_feat4: string;
  pricing_premium_feat5: string;
  pricing_premium_feat6: string;
  pricing_premium_feat7: string;
  pricing_premium_feat8: string;
  pricing_premium_feat9: string;
  pricing_premium_feat10: string;
  pricing_family_name: string;
  pricing_family_price_monthly: string;
  pricing_family_price_yearly: string;
  pricing_family_period_monthly: string;
  pricing_family_period_yearly: string;
  pricing_family_desc: string;
  pricing_family_cta: string;
  pricing_family_feat1: string;
  pricing_family_feat2: string;
  pricing_family_feat3: string;
  pricing_family_feat4: string;
  pricing_family_feat5: string;
  pricing_family_feat6: string;
  pricing_family_feat7: string;
  footer_pricing_link: string;
  nav_delete_account: string;
  delete_title: string;
  delete_last_updated: string;
  delete_intro: string;
  delete_steps_title: string;
  delete_step1: string;
  delete_step2: string;
  delete_step3: string;
  delete_step4: string;
  delete_alt_title: string;
  delete_alt_desc: string;
  delete_data_title: string;
  delete_data_deleted_title: string;
  delete_data_deleted1: string;
  delete_data_deleted2: string;
  delete_data_deleted3: string;
  delete_data_deleted4: string;
  delete_data_deleted5: string;
  delete_data_deleted6: string;
  delete_data_retained_title: string;
  delete_data_retained1: string;
  delete_data_retained2: string;
  delete_timeline_title: string;
  delete_timeline1: string;
  delete_timeline2: string;
  delete_timeline3: string;
  delete_subscription_title: string;
  delete_subscription_desc: string;
  delete_important_title: string;
  delete_important_desc: string;
  delete_contact_title: string;
  delete_contact_desc: string;
  delete_see_also: string;
  delete_privacy_link: string;
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
    hero_badge: "Nova versão 2026 — a app de orçamento #1 feita em Portugal",
    hero_title_line1: "Sabes exatamente para onde",
    hero_title_line2: "vai cada euro do teu mês",
    hero_subtitle: "Junta-te às famílias portuguesas que já controlam o IRS, as compras do supermercado e cada cêntimo do mês — sem folhas de Excel, sem apps complicadas. Começa grátis, sem compromisso.",
    hero_cta_primary: "Experimentar Grátis",
    hero_cta_secondary: "Descobre Como Funciona",
    stat1_value: "< 5 min",
    stat1_label: "Para começar",
    stat2_value: "€180",
    stat2_label: "Média poupada/mês",
    stat3_value: "21 dias",
    stat3_label: "Teste grátis",
    stat4_value: "100%",
    stat4_label: "Dados no teu telemóvel",
    mockup_title: "Orçamento Mensal",
    mockup_net_label: "Rendimento Líquido",
    mockup_expenses_label: "Despesas",
    mockup_savings_label: "Poupança",
    mockup_trend_label: "Tendência Mensal",
    mockup_label: "Dashboard",
    float1: "+€619 poupados este mês!",
    float2: "IRS calculado em 3 segundos",
    float3: "Lista de compras: €47,80",
    trust1: "Dados 100% no teu telemóvel — nunca saem de lá",
    trust2: "Experimenta grátis — sem cartão de crédito",
    trust3: "Tabelas IRS oficiais integradas e atualizadas",
    trust4: "Feita em Portugal, com cuidado e RGPD",
    how_title: "Começa em 3 passos simples",
    how_desc: "Do download ao primeiro mês sob controlo — demora menos do que fazer um café.",
    how_step1_title: "Descarrega a app",
    how_step1_desc: "Disponível na Google Play. Começa grátis com todas as funcionalidades — sem cartão de crédito.",
    how_step2_title: "Configura em 5 minutos",
    how_step2_desc: "Introduz o teu rendimento e as tuas despesas fixas. A app organiza o teu mês inteiro automaticamente.",
    how_step3_title: "Vê o teu mês ganhar forma",
    how_step3_desc: "O dashboard mostra para onde vai cada euro. Começas a poupar sem mudar a tua vida — só a entendê-la melhor.",
    features_title: "6 ferramentas. 6 problemas resolvidos. 0 desculpas.",
    features_desc: "Cada funcionalidade existe porque alguém nos disse: \u201CEu preciso disto e não encontro em lado nenhum.\u201D",
    feat1_title: "O Teu Mês Inteiro, Num Só Ecrã",
    feat1_desc: "Abre a app e vê imediatamente: quanto ganhas, quanto já gastaste, e quanto te resta — por categoria, ao cêntimo. Imagina chegares ao dia 25 e saberes, com certeza, que a renda, as propinas e o supermercado estão cobertos. É essa a sensação.",
    feat2_title: "Impostos Calculados em Segundos",
    feat2_desc: "Introduz o teu salário bruto e, em 2 segundos, vês o líquido exato que cai na conta — com tabelas de IRS 2026 integradas, taxa efetiva e deduções. Suporte para Portugal, Espanha, França e Reino Unido. Nunca mais abres aquele simulador duvidoso que te dá um número diferente de cada vez.",
    feat3_title: "Entra no Supermercado com Tudo Decidido",
    feat3_desc: "Antes de saíres de casa, a app mostra-te: \u201CEsta semana, as tuas compras ficam em ±€47,80.\u201D Crias a lista, vês os preços que registaste, e sabes o total antes de pegares no carrinho. Nada de surpresas na caixa. Controlo total, compra a compra.",
    feat4_title: "O Orçamento da Família, em Tempo Real",
    feat4_desc: "O João adiciona a conta do gás. A Maria risca o leite da lista. As crianças veem que faltam €15 para o passeio de domingo. Todos a olhar para o mesmo ecrã, todos a remar para o mesmo lado — sem discussões sobre dinheiro ao jantar.",
    feat5_title: "30 Dias de Refeições Que Cabem no Orçamento",
    feat5_desc: "Segunda: sopa + frango grelhado. Terça: massa carbonara. A app planeia 30 dias de refeições e gera a lista de compras com os custos estimados. Resultado? Menos desperdício, menos \u201Co que vamos jantar?\u201D e uma conta do supermercado que finalmente faz sentido.",
    feat6_title: "Um Coach Financeiro Que Aprende Contigo",
    feat6_desc: "\u201CMaria, este mês gastaste 23% mais em restaurantes. Se cozinhares 2× mais em casa, poupas ±€85.\u201D A IA analisa os teus padrões reais e dá sugestões concretas — não genéricas. É como ter um consultor financeiro no bolso, disponível 24h, que sabe exatamente como tu gastas.",
    screens_title: "5 ecrãs. Zero confusão. Controlo absoluto.",
    screens_desc: "Cada ecrã dá-te respostas em segundos — não mais perguntas.",
    screen1_title: "Dashboard",
    screen1_desc: "Rendimento, despesas, poupança e tendência mensal — tudo num relance. Sabes em 3 segundos se o mês está a correr bem ou se precisas de ajustar.",
    screen2_title: "Supermercado",
    screen2_desc: "Consulta preços de 248+ produtos, compara marcas e guarda o histórico para saberes quando um preço sobe ou desce.",
    screen3_title: "Lista de Compras",
    screen3_desc: "Partilhada com a família, atualizada ao segundo. Cada item tem preço estimado — o total da compra aparece antes de saíres de casa.",
    screen4_title: "Refeições",
    screen4_desc: "Planeia almoço e jantar para a semana inteira. A lista de ingredientes é gerada automaticamente — zero decisões no momento.",
    screen5_title: "Coach IA",
    screen5_desc: "Faz perguntas sobre o teu orçamento e recebe respostas personalizadas. \u201CPosso jantar fora este sábado?\u201D — o coach sabe a resposta.",
    cta_title: "O próximo mês não tem de ser como o último.",
    cta_desc: "Junta-te às famílias portuguesas que deixaram de sobreviver ao mês e começaram a dominá-lo. Começa grátis e sem compromisso. Sem dados enviados para lado nenhum. Só tu e o teu dinheiro — finalmente em paz.",
    cta_button: "Experimentar Grátis",
    cta_micro: "Sem cartão de crédito. Leva menos de 5 minutos a configurar. O teu próximo mês agradece.",
    footer_desc: "A app que está a mudar a forma como as famílias portuguesas vivem o dinheiro. Feita em Portugal, com orgulho.",
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
    timeline_intro: "A Maria tem 34 anos, vive em Lisboa com o João e dois filhos. Ganha €1.400 líquidos. Todos os meses, o dinheiro parece evaporar antes do dia 20. Esta é a história do mês em que isso mudou.",
    timeline_day1_title: "\u201CO dinheiro desaparece e eu não sei para onde\u201D",
    timeline_day1_pain: "É domingo à noite. A Maria senta-se à mesa da cozinha com uma pilha de recibos e o extrato do banco aberto no telemóvel. Tenta fazer contas, mas os números não batem. Fecha tudo, frustrada. Amanhã é dia 1 e ela já sente o aperto.",
    timeline_day1_resolution: "Em menos de 10 minutos, introduz o rendimento e as despesas fixas na app. Pela primeira vez, vê o mês inteiro num ecrã: quanto entra, quanto já está comprometido, e quanto sobra para o dia-a-dia. Respira fundo. Agora tem um plano.",
    timeline_day5_title: "\u201CA conta do gás quase me escapou — outra vez\u201D",
    timeline_day5_pain: "Maria recebe um SMS do banco: saldo abaixo dos €200. O coração acelera. A conta do gás vence amanhã e ela tinha-se esquecido. É o mesmo stress de todos os meses — essa sensação de estar sempre a correr atrás do prejuízo.",
    timeline_day5_resolution: "Mas desta vez, a app já tinha enviado um lembrete ontem. Pagou a conta calmamente, sem urgência, sem medo. Um alerta simples. Uma preocupação a menos. O estômago, pela primeira vez, não se apertou.",
    timeline_day9_title: "\u201C\u2018O que vamos jantar?\u2019 — a pergunta que custava €200 por mês\u201D",
    timeline_day9_pain: "Todos os dias, por volta das 18h, a mesma conversa: \u201CO que vamos comer?\u201D Ninguém sabe. Ninguém decidiu. Resultado? Takeaway de última hora ou mais uma ida ao supermercado sem lista — e mais €15 que ninguém planeou gastar.",
    timeline_day9_resolution: "O plano de refeições da semana está pronto desde domingo. A lista de compras foi gerada automaticamente, com quantidades e preços estimados. Entrou no supermercado, comprou exatamente o que precisava, e saiu em 25 minutos. Sem stress. Sem impulsos. Sem culpa.",
    timeline_day14_title: "\u201CMetade do mês. A verdade dói — mas há um plano.\u201D",
    timeline_day14_pain: "O João abre a app e vê o aviso: já gastaram 68% do orçamento de restaurantes e só estão a meio do mês. Sente culpa. A Maria sente frustração. O ambiente fica tenso.",
    timeline_day14_resolution: "Mas a app não julga — mostra o impacto e sugere alternativas. Decidem juntos cozinhar este fim de semana. Não por castigo, mas porque veem os números e sentem que estão a escolher, em vez de reagir. A tensão desfaz-se. Estão a trabalhar em equipa.",
    timeline_day18_title: "\u201CEntrar no supermercado sem medo — pela primeira vez em anos\u201D",
    timeline_day18_pain: "Antes, cada ida ao supermercado era um exercício de ansiedade. Levar mais ou menos? Este preço é bom? Estou a gastar demais? A caixa registadora era um momento de verdade que a Maria temia.",
    timeline_day18_resolution: "Hoje, abre a app e vê: lista de 23 produtos, total estimado de €47,80. Sabe exatamente o que vai comprar e quanto vai custar. Na fila da caixa, o total real é €49,20. Diferença de €1,40. A Maria sorri. Isto é controlo.",
    timeline_day25_title: "\u201CRenda paga. Propinas pagas. E ainda sobra.\u201D",
    timeline_day25_pain: "O dia 25 costumava ser o pior dia do mês. Renda, propinas do filho mais velho, seguro do carro — tudo de uma vez. Passava a semana anterior sem dormir direito, a fazer contas e recontas.",
    timeline_day25_resolution: "Desta vez, abre o dashboard e confirma: renda coberta, propinas cobertas, seguro coberto. Restam €120 para a última semana. Não é sorte — é o resultado de um mês inteiro com um plano. Liga à mãe e, pela primeira vez, não desliga a pensar no dinheiro.",
    timeline_day30_title: "\u201C€180 poupados. Zero sacrifício. Um sorriso enorme.\u201D",
    timeline_day30_pain: "Nos últimos anos, acabar o mês sem ficar no vermelho já era uma vitória. Poupar? Parecia coisa de outra gente. De gente que ganha mais, que tem menos contas, que nasceu com sorte.",
    timeline_day30_resolution: "E no entanto, aqui está: €180 poupados. Sem cortar no que gostam. Sem viver em modo de sobrevivência. A app mostra uma sequência de 30 dias de hábitos saudáveis e sugere criar um fundo de emergência. A Maria mostra o ecrã ao João. Ele sorri. Ela também. O próximo mês já não mete medo.",
    faq_title: "Perguntas Frequentes",
    faq1_q: "A app é grátis?",
    faq1_a: "Sim, podes usar a app gratuitamente com funcionalidades essenciais. Ao instalar, tens acesso a tudo durante 21 dias para experimentares à vontade. Depois, decides se queres continuar grátis ou ativar um plano.",
    faq2_q: "Os meus dados ficam seguros?",
    faq2_a: "Todos os dados ficam guardados localmente no teu telemóvel. Não enviamos nada para servidores externos. Tu és o único dono da tua informação financeira.",
    faq3_q: "Preciso de ligar a minha conta bancária?",
    faq3_a: "Não. A app funciona com os valores que tu introduzes manualmente. Sem acesso ao banco, sem risco.",
    faq4_q: "Funciona para famílias ou só para uma pessoa?",
    faq4_a: "Para as duas coisas. Podes usar sozinho ou partilhar o orçamento e as listas de compras com quem vive contigo.",
    faq5_q: "As tabelas de IRS estão atualizadas?",
    faq5_a: "Sim. Usamos as tabelas oficiais de retenção na fonte de IRS publicadas pela Autoridade Tributária, atualizadas para 2026.",
    faq6_q: "A app funciona em iOS / iPhone?",
    faq6_a: "De momento, a Gestão Mensal está disponível apenas para Android. Estamos a trabalhar na versão iOS.",
    faq7_q: "Preciso de cartão de crédito para o teste grátis?",
    faq7_a: "Não. O teste de 21 dias é totalmente gratuito e não pede dados de pagamento. Só os introduzes se decidires subscrever um plano.",
    faq8_q: "Posso cancelar a subscrição a qualquer momento?",
    faq8_a: "Sim. Podes cancelar quando quiseres, diretamente na Google Play. Manténs o acesso até ao fim do período pago e depois passas ao plano gratuito.",
    nav_pricing: "Preços",
    pricing_title: "Um plano para cada tipo de família",
    pricing_desc: "Começa com 21 dias grátis. Sem cartão de crédito. Cancela quando quiseres.",
    pricing_toggle_monthly: "Mensal",
    pricing_toggle_yearly: "Anual",
    pricing_save_badge: "Poupa 37%",
    pricing_trial_banner: "21 dias grátis em todos os planos",
    pricing_free_name: "Gratuito",
    pricing_free_price: "€0",
    pricing_free_period: "para sempre",
    pricing_free_desc: "Para quem quer começar a organizar as finanças com o essencial.",
    pricing_free_cta: "Começar Grátis",
    pricing_free_feat1: "Calculadora de orçamento (8 categorias)",
    pricing_free_feat2: "Registo de despesas (mês atual)",
    pricing_free_feat3: "1 objetivo de poupança",
    pricing_free_feat4: "Lista de compras (local)",
    pricing_free_feat5: "Anúncios banner",
    pricing_premium_name: "Premium",
    pricing_premium_price_monthly: "€3,99",
    pricing_premium_price_yearly: "€29,99",
    pricing_premium_period_monthly: "/mês",
    pricing_premium_period_yearly: "/ano",
    pricing_premium_desc: "Para quem quer controlo total sobre o orçamento e acesso a ferramentas inteligentes.",
    pricing_premium_cta: "Começar Teste Grátis",
    pricing_premium_popular: "Mais Popular",
    pricing_premium_feat1: "Categorias e histórico ilimitados",
    pricing_premium_feat2: "Coach Financeiro com IA",
    pricing_premium_feat3: "Plano de refeições + receitas IA",
    pricing_premium_feat4: "Sincronização da lista de compras",
    pricing_premium_feat5: "Exportação PDF/CSV",
    pricing_premium_feat6: "Lembretes de contas",
    pricing_premium_feat7: "Sem anúncios",
    pricing_premium_feat8: "Tendências e gráficos de despesas",
    pricing_premium_feat9: "Objetivos de poupança ilimitados",
    pricing_premium_feat10: "Gestão de despesas recorrentes",
    pricing_family_name: "Família",
    pricing_family_price_monthly: "€6,99",
    pricing_family_price_yearly: "€49,99",
    pricing_family_period_monthly: "/mês",
    pricing_family_period_yearly: "/ano",
    pricing_family_desc: "Para famílias que querem gerir tudo juntas — orçamento, compras e refeições.",
    pricing_family_cta: "Começar Teste Grátis",
    pricing_family_feat1: "Tudo do Premium",
    pricing_family_feat2: "Partilha familiar (até 6 pessoas)",
    pricing_family_feat3: "Simulador de impostos multi-país",
    pricing_family_feat4: "Índice de stress + sequências",
    pricing_family_feat5: "Relatórios de fim de mês",
    pricing_family_feat6: "Dashboard personalizável",
    pricing_family_feat7: "Todos os temas de cores",
    footer_pricing_link: "Preços",
    nav_delete_account: "Eliminar Conta",
    delete_title: "Eliminar Conta e Dados",
    delete_last_updated: "Última atualização: 14 de março de 2026",
    delete_intro: "Na Gestão Mensal, respeitamos o seu direito a controlar os seus dados pessoais. Esta página explica como pode solicitar a eliminação da sua conta e de todos os dados associados.",
    delete_steps_title: "Como eliminar a sua conta",
    delete_step1: "Abra a app Gestão Mensal no seu dispositivo Android.",
    delete_step2: "Vá a Definições (ícone de engrenagem no canto superior).",
    delete_step3: "Deslize até ao fundo e toque em \"Eliminar conta e dados\".",
    delete_step4: "Confirme a eliminação. A sua conta e todos os dados serão removidos permanentemente.",
    delete_alt_title: "Método alternativo: por email",
    delete_alt_desc: "Se não conseguir aceder à app, pode solicitar a eliminação enviando um email a partir do endereço associado à sua conta:",
    delete_data_title: "Dados que são eliminados vs. retidos",
    delete_data_deleted_title: "Dados eliminados permanentemente (no prazo de 30 dias):",
    delete_data_deleted1: "Dados da conta (email, nome, preferências)",
    delete_data_deleted2: "Dados financeiros (rendimentos, despesas, orçamentos, metas de poupança)",
    delete_data_deleted3: "Listas de compras e histórico de preços",
    delete_data_deleted4: "Planos de refeições e preferências alimentares",
    delete_data_deleted5: "Histórico de interações com o Coach Financeiro IA",
    delete_data_deleted6: "Dados de sincronização e partilha familiar",
    delete_data_retained_title: "Dados que podem ser retidos:",
    delete_data_retained1: "Registos de transações de pagamento (processados pela Google Play) — retidos pela Google de acordo com as suas obrigações legais e fiscais. A Gestão Mensal não tem acesso a estes dados.",
    delete_data_retained2: "Dados anonimizados e agregados que já não permitam a identificação do utilizador, utilizados para melhorar o serviço.",
    delete_timeline_title: "Prazos de eliminação",
    delete_timeline1: "A conta é desativada imediatamente após o pedido.",
    delete_timeline2: "Todos os dados pessoais são eliminados dos nossos servidores no prazo de 30 dias.",
    delete_timeline3: "Os dados locais no seu dispositivo são removidos quando desinstala a app.",
    delete_subscription_title: "Subscrições ativas",
    delete_subscription_desc: "A eliminação da conta não cancela automaticamente a sua subscrição na Google Play. Para evitar cobranças futuras, cancele a subscrição antes de eliminar a conta: Google Play > Subscrições > Gestão Mensal > Cancelar.",
    delete_important_title: "Importante",
    delete_important_desc: "A eliminação da conta é permanente e irreversível. Todos os dados serão perdidos e não poderão ser recuperados. Se tiver um plano Premium ou Família, recomendamos que exporte os seus dados (PDF/CSV) antes de proceder à eliminação.",
    delete_contact_title: "Questões?",
    delete_contact_desc: "Se tiver dúvidas sobre a eliminação da sua conta ou dos seus dados, contacte-nos:",
    delete_see_also: "Consulte também a nossa",
    delete_privacy_link: "Política de Privacidade",
    privacy_title: "Política de Privacidade",
    privacy_last_updated: "Última atualização: 14 de março de 2026",
    terms_title: "Termos de Utilização",
    terms_last_updated: "Última atualização: 14 de março de 2026",
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
    hero_badge: "New 2026 version — the #1 budget app made in Portugal",
    hero_title_line1: "Know exactly where",
    hero_title_line2: "every euro of your month goes",
    hero_subtitle: "Join the families already controlling their taxes, groceries and every cent of the month — no spreadsheets, no complicated apps. Start free, no strings attached.",
    hero_cta_primary: "Try It Free",
    hero_cta_secondary: "See How It Works",
    stat1_value: "< 5 min",
    stat1_label: "To get started",
    stat2_value: "€180",
    stat2_label: "Avg. saved/month",
    stat3_value: "21 days",
    stat3_label: "Free trial",
    stat4_value: "100%",
    stat4_label: "Data on your phone",
    mockup_title: "Monthly Budget",
    mockup_net_label: "Net Income",
    mockup_expenses_label: "Expenses",
    mockup_savings_label: "Savings",
    mockup_trend_label: "Monthly Trend",
    mockup_label: "Dashboard",
    float1: "+€619 saved this month!",
    float2: "Tax calculated in 3 seconds",
    float3: "Shopping list: €47.80",
    trust1: "Data stays 100% on your phone — never leaves",
    trust2: "Try free — no credit card required",
    trust3: "Official Portuguese IRS tax tables built in",
    trust4: "Made in Portugal, with care and GDPR compliance",
    how_title: "Start in 3 simple steps",
    how_desc: "From download to your first month under control — takes less time than making a coffee.",
    how_step1_title: "Download the app",
    how_step1_desc: "Available on Google Play. Start free with all features — no credit card required.",
    how_step2_title: "Set up in 5 minutes",
    how_step2_desc: "Enter your income and fixed expenses. The app organizes your entire month automatically.",
    how_step3_title: "Watch your month take shape",
    how_step3_desc: "The dashboard shows where every euro goes. Start saving without changing your life — just understanding it better.",
    features_title: "6 tools. 6 problems solved. 0 excuses.",
    features_desc: "Every feature exists because someone told us: \u201CI need this and I can\u2019t find it anywhere.\u201D",
    feat1_title: "Your Entire Month on One Screen",
    feat1_desc: "Open the app and see instantly: how much you earn, how much you\u2019ve spent, and how much is left — by category, to the cent. Imagine reaching day 25 and knowing for certain that rent, tuition and groceries are covered. That\u2019s the feeling.",
    feat2_title: "Taxes Calculated in Seconds",
    feat2_desc: "Enter your gross salary and, in 2 seconds, see the exact net amount that hits your account — with 2026 tax tables built in, effective rate and deductions. Supports Portugal, Spain, France and the UK. Never open that dodgy simulator that gives you a different number every time.",
    feat3_title: "Walk Into the Supermarket with Everything Decided",
    feat3_desc: "Before leaving home, the app tells you: \u201CThis week, your groceries come to \u00b1\u20AC47.80.\u201D Create the list, see the prices you recorded, and know the total before grabbing a cart. No checkout surprises. Total control, purchase by purchase.",
    feat4_title: "The Family Budget, in Real Time",
    feat4_desc: "João adds the gas bill. Maria crosses milk off the list. The kids see that \u20AC15 is left for Sunday\u2019s outing. Everyone looking at the same screen, everyone rowing in the same direction — no dinner-table arguments about money.",
    feat5_title: "30 Days of Meals That Fit the Budget",
    feat5_desc: "Monday: soup + grilled chicken. Tuesday: carbonara. The app plans 30 days of meals and generates the shopping list with estimated costs. Result? Less waste, fewer \u201Cwhat\u2019s for dinner?\u201D moments and a grocery bill that finally makes sense.",
    feat6_title: "A Financial Coach That Learns With You",
    feat6_desc: "\u201CMaria, this month you spent 23% more on restaurants. If you cook 2\u00d7 more at home, you\u2019d save \u00b1\u20AC85.\u201D The AI analyses your real patterns and gives concrete suggestions — not generic ones. Like having a financial advisor in your pocket, 24/7, who knows exactly how you spend.",
    screens_title: "5 screens. Zero confusion. Absolute control.",
    screens_desc: "Each screen gives you answers in seconds — not more questions.",
    screen1_title: "Dashboard",
    screen1_desc: "Income, expenses, savings and monthly trend — all at a glance. Know in 3 seconds if the month is on track or needs adjusting.",
    screen2_title: "Supermarket",
    screen2_desc: "Browse prices of 248+ products, compare brands, and track history to know when a price rises or drops.",
    screen3_title: "Shopping List",
    screen3_desc: "Shared with family, updated instantly. Every item has an estimated price — the total shows up before you leave home.",
    screen4_title: "Meals",
    screen4_desc: "Plan lunch and dinner for the whole week. The ingredient list is generated automatically — zero last-minute decisions.",
    screen5_title: "AI Coach",
    screen5_desc: "Ask questions about your budget and get personalised answers. \u201CCan I eat out this Saturday?\u201D — the coach knows the answer.",
    cta_title: "Next month doesn\u2019t have to be like the last.",
    cta_desc: "Join the families who stopped surviving the month and started owning it. Start free, no commitment. No data sent anywhere. Just you and your money — finally at peace.",
    cta_button: "Try It Free",
    cta_micro: "No credit card required. Takes less than 5 minutes to set up. Your next month will thank you.",
    footer_desc: "The app changing how families experience money. Made in Portugal, with pride.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Features",
    footer_screens_link: "Screens",
    footer_download_link: "Download",
    footer_privacy_link: "Privacy Policy",
    footer_terms_link: "Terms of Use",
    footer_copyright: "© 2026 Gestão Mensal. All rights reserved.",
    footer_made_in: "Made with care in Portugal",
    timeline_title: "30 days that turned Maria\u2019s life around",
    timeline_subtitle: "One full month. Real challenges. Life-changing wins. Follow every step.",
    timeline_intro: "Maria is 34, lives in Lisbon with João and two kids. She earns \u20AC1,400 net. Every month, money seems to vanish before the 20th. This is the story of the month that changed.",
    timeline_day1_title: "\u201CMy money disappears and I don\u2019t know where\u201D",
    timeline_day1_pain: "It\u2019s Sunday evening. Maria sits at the kitchen table with a pile of receipts and her bank statement open on her phone. She tries to do the maths, but the numbers don\u2019t add up. She closes everything, frustrated. Tomorrow is the 1st and she already feels the squeeze.",
    timeline_day1_resolution: "In less than 10 minutes, she enters her income and fixed expenses in the app. For the first time, she sees the entire month on one screen: what comes in, what\u2019s already committed, and what\u2019s left for day-to-day. She takes a deep breath. Now she has a plan.",
    timeline_day5_title: "\u201CThe gas bill nearly slipped past me — again\u201D",
    timeline_day5_pain: "Maria gets a text from the bank: balance below \u20AC200. Her heart races. The gas bill is due tomorrow and she\u2019d forgotten. Same stress every month — that feeling of always chasing the damage.",
    timeline_day5_resolution: "But this time, the app had already sent a reminder yesterday. She paid calmly, without urgency, without fear. One simple alert. One less worry. For the first time, her stomach didn\u2019t clench.",
    timeline_day9_title: "\u201C\u2018What\u2019s for dinner?\u2019 — the question that cost \u20AC200 a month\u201D",
    timeline_day9_pain: "Every day around 6pm, the same conversation: \u201CWhat are we eating?\u201D Nobody knows. Nobody decided. Result? Last-minute takeaway or another unplanned supermarket trip — and another \u20AC15 nobody budgeted for.",
    timeline_day9_resolution: "The weekly meal plan has been ready since Sunday. The shopping list was generated automatically, with quantities and estimated prices. She walked into the supermarket, bought exactly what she needed, and was out in 25 minutes. No stress. No impulse buys. No guilt.",
    timeline_day14_title: "\u201CHalf the month gone. The truth hurts — but there\u2019s a plan.\u201D",
    timeline_day14_pain: "João opens the app and sees the alert: they\u2019ve already used 68% of the restaurant budget and they\u2019re only halfway through the month. Guilt. Maria feels frustration. The mood turns tense.",
    timeline_day14_resolution: "But the app doesn\u2019t judge — it shows the impact and suggests alternatives. They decide together to cook this weekend. Not as punishment, but because they can see the numbers and feel they\u2019re choosing, not reacting. The tension dissolves. They\u2019re working as a team.",
    timeline_day18_title: "\u201CWalking into the supermarket without fear — for the first time in years\u201D",
    timeline_day18_pain: "Before, every supermarket trip was an anxiety exercise. Take more or less? Is this price good? Am I overspending? The checkout was a moment of truth Maria dreaded.",
    timeline_day18_resolution: "Today, she opens the app and sees: 23 items, estimated total \u20AC47.80. She knows exactly what she\u2019ll buy and how much it\u2019ll cost. At the checkout, the real total is \u20AC49.20. Difference: \u20AC1.40. Maria smiles. This is control.",
    timeline_day25_title: "\u201CRent paid. Tuition paid. And there\u2019s still money left.\u201D",
    timeline_day25_pain: "The 25th used to be the worst day of the month. Rent, eldest\u2019s tuition, car insurance — all at once. She\u2019d spend the previous week barely sleeping, doing sums over and over.",
    timeline_day25_resolution: "This time, she opens the dashboard and confirms: rent covered, tuition covered, insurance covered. \u20AC120 left for the last week. It\u2019s not luck — it\u2019s the result of an entire month with a plan. She calls her mum and, for the first time, doesn\u2019t hang up thinking about money.",
    timeline_day30_title: "\u201C\u20AC180 saved. Zero sacrifice. One huge smile.\u201D",
    timeline_day30_pain: "In recent years, finishing the month without going into the red was already a victory. Saving? That seemed like something for other people. People who earn more, have fewer bills, were born lucky.",
    timeline_day30_resolution: "And yet, here it is: \u20AC180 saved. Without cutting what they love. Without survival mode. The app shows a 30-day streak of healthy habits and suggests starting an emergency fund. Maria shows the screen to João. He smiles. She does too. Next month no longer feels scary.",
    faq_title: "Frequently Asked Questions",
    faq1_q: "Is the app free?",
    faq1_a: "Yes, you can use the app for free with essential features. When you install, you get full access to everything for 21 days. After that, you decide whether to stay free or activate a plan.",
    faq2_q: "Is my data secure?",
    faq2_a: "All data is stored locally on your phone. We don\u2019t send anything to external servers. You are the sole owner of your financial information.",
    faq3_q: "Do I need to link my bank account?",
    faq3_a: "No. The app works with values you enter manually. No bank access, no risk.",
    faq4_q: "Does it work for families or just individuals?",
    faq4_a: "Both. You can use it solo or share the budget and shopping lists with everyone at home.",
    faq5_q: "Are the IRS tax tables up to date?",
    faq5_a: "Yes. We use the official withholding tax tables published by the Portuguese Tax Authority, updated for 2026.",
    faq6_q: "Does the app work on iOS / iPhone?",
    faq6_a: "Currently, Gestão Mensal is available for Android only. We\u2019re working on the iOS version.",
    faq7_q: "Do I need a credit card for the free trial?",
    faq7_a: "No. The 21-day trial is completely free and doesn\u2019t ask for payment details. You only enter them if you decide to subscribe.",
    faq8_q: "Can I cancel my subscription at any time?",
    faq8_a: "Yes. You can cancel whenever you want, directly through Google Play. You keep access until the end of the paid period, then switch to the free plan.",
    nav_pricing: "Pricing",
    pricing_title: "A plan for every kind of family",
    pricing_desc: "Start with 21 days free. No credit card. Cancel anytime.",
    pricing_toggle_monthly: "Monthly",
    pricing_toggle_yearly: "Yearly",
    pricing_save_badge: "Save 37%",
    pricing_trial_banner: "21 days free on all plans",
    pricing_free_name: "Free",
    pricing_free_price: "€0",
    pricing_free_period: "forever",
    pricing_free_desc: "For anyone ready to start organising their finances with the essentials.",
    pricing_free_cta: "Get Started Free",
    pricing_free_feat1: "Budget calculator (8 categories)",
    pricing_free_feat2: "Expense tracking (current month)",
    pricing_free_feat3: "1 savings goal",
    pricing_free_feat4: "Shopping list (local only)",
    pricing_free_feat5: "Banner ads",
    pricing_premium_name: "Premium",
    pricing_premium_price_monthly: "€3.99",
    pricing_premium_price_yearly: "€29.99",
    pricing_premium_period_monthly: "/mo",
    pricing_premium_period_yearly: "/yr",
    pricing_premium_desc: "For those who want full control over their budget and access to smart tools.",
    pricing_premium_cta: "Start Free Trial",
    pricing_premium_popular: "Most Popular",
    pricing_premium_feat1: "Unlimited categories & history",
    pricing_premium_feat2: "AI Financial Coach",
    pricing_premium_feat3: "Meal planner + AI recipes",
    pricing_premium_feat4: "Real-time shopping list sync",
    pricing_premium_feat5: "PDF/CSV export",
    pricing_premium_feat6: "Bill reminders",
    pricing_premium_feat7: "No ads",
    pricing_premium_feat8: "Expense trends & charts",
    pricing_premium_feat9: "Unlimited savings goals",
    pricing_premium_feat10: "Recurring expense management",
    pricing_family_name: "Family",
    pricing_family_price_monthly: "€6.99",
    pricing_family_price_yearly: "€49.99",
    pricing_family_period_monthly: "/mo",
    pricing_family_period_yearly: "/yr",
    pricing_family_desc: "For families who want to manage everything together — budget, shopping and meals.",
    pricing_family_cta: "Start Free Trial",
    pricing_family_feat1: "Everything in Premium",
    pricing_family_feat2: "Household sharing (up to 6)",
    pricing_family_feat3: "Multi-country tax simulator",
    pricing_family_feat4: "Stress index + streaks",
    pricing_family_feat5: "Month-in-review reports",
    pricing_family_feat6: "Dashboard customization",
    pricing_family_feat7: "All color themes",
    footer_pricing_link: "Pricing",
    nav_delete_account: "Delete Account",
    delete_title: "Delete Account & Data",
    delete_last_updated: "Last updated: March 14, 2026",
    delete_intro: "At Gestão Mensal, we respect your right to control your personal data. This page explains how you can request the deletion of your account and all associated data.",
    delete_steps_title: "How to delete your account",
    delete_step1: "Open the Gestão Mensal app on your Android device.",
    delete_step2: "Go to Settings (gear icon in the top corner).",
    delete_step3: "Scroll to the bottom and tap \"Delete account and data\".",
    delete_step4: "Confirm the deletion. Your account and all data will be permanently removed.",
    delete_alt_title: "Alternative method: by email",
    delete_alt_desc: "If you can\u2019t access the app, you can request deletion by sending an email from the address associated with your account:",
    delete_data_title: "Data that is deleted vs. retained",
    delete_data_deleted_title: "Data permanently deleted (within 30 days):",
    delete_data_deleted1: "Account data (email, name, preferences)",
    delete_data_deleted2: "Financial data (income, expenses, budgets, savings goals)",
    delete_data_deleted3: "Shopping lists and price history",
    delete_data_deleted4: "Meal plans and dietary preferences",
    delete_data_deleted5: "AI Financial Coach interaction history",
    delete_data_deleted6: "Sync and family sharing data",
    delete_data_retained_title: "Data that may be retained:",
    delete_data_retained1: "Payment transaction records (processed by Google Play) \u2014 retained by Google in accordance with their legal and tax obligations. Gestão Mensal does not have access to this data.",
    delete_data_retained2: "Anonymized and aggregated data that can no longer identify the user, used to improve the service.",
    delete_timeline_title: "Deletion timeline",
    delete_timeline1: "The account is deactivated immediately after the request.",
    delete_timeline2: "All personal data is deleted from our servers within 30 days.",
    delete_timeline3: "Local data on your device is removed when you uninstall the app.",
    delete_subscription_title: "Active subscriptions",
    delete_subscription_desc: "Deleting your account does not automatically cancel your Google Play subscription. To avoid future charges, cancel your subscription before deleting your account: Google Play > Subscriptions > Gestão Mensal > Cancel.",
    delete_important_title: "Important",
    delete_important_desc: "Account deletion is permanent and irreversible. All data will be lost and cannot be recovered. If you have a Premium or Family plan, we recommend exporting your data (PDF/CSV) before proceeding.",
    delete_contact_title: "Questions?",
    delete_contact_desc: "If you have questions about deleting your account or data, contact us:",
    delete_see_also: "See also our",
    delete_privacy_link: "Privacy Policy",
    privacy_title: "Privacy Policy",
    privacy_last_updated: "Last updated: March 14, 2026",
    terms_title: "Terms of Use",
    terms_last_updated: "Last updated: March 14, 2026",
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
    hero_badge: "Nueva versión 2026 — la app de presupuesto #1 hecha en Portugal",
    hero_title_line1: "Sabes exactamente a dónde",
    hero_title_line2: "va cada euro de tu mes",
    hero_subtitle: "Únete a las familias que ya controlan sus impuestos, las compras del supermercado y cada céntimo del mes — sin hojas de Excel, sin apps complicadas. Empieza gratis, sin compromiso.",
    hero_cta_primary: "Probar Gratis",
    hero_cta_secondary: "Descubre Cómo Funciona",
    stat1_value: "< 5 min",
    stat1_label: "Para empezar",
    stat2_value: "€180",
    stat2_label: "Media ahorrada/mes",
    stat3_value: "21 días",
    stat3_label: "Prueba gratis",
    stat4_value: "100%",
    stat4_label: "Datos en tu móvil",
    mockup_title: "Presupuesto Mensual",
    mockup_net_label: "Ingreso Neto",
    mockup_expenses_label: "Gastos",
    mockup_savings_label: "Ahorros",
    mockup_trend_label: "Tendencia Mensual",
    mockup_label: "Dashboard",
    float1: "+€619 ahorrados este mes!",
    float2: "IRS calculado en 3 segundos",
    float3: "Lista de compras: €47,80",
    trust1: "Datos 100% en tu móvil — nunca salen de ahí",
    trust2: "Prueba gratis — sin tarjeta de crédito",
    trust3: "Tablas IRS oficiales integradas y actualizadas",
    trust4: "Hecha en Portugal, con cuidado y RGPD",
    how_title: "Empieza en 3 pasos simples",
    how_desc: "De la descarga a tu primer mes bajo control — lleva menos tiempo que preparar un café.",
    how_step1_title: "Descarga la app",
    how_step1_desc: "Disponible en Google Play. Empieza gratis con todas las funcionalidades — sin tarjeta de crédito.",
    how_step2_title: "Configura en 5 minutos",
    how_step2_desc: "Introduce tus ingresos y gastos fijos. La app organiza tu mes entero automáticamente.",
    how_step3_title: "Mira cómo tu mes toma forma",
    how_step3_desc: "El dashboard muestra a dónde va cada euro. Empiezas a ahorrar sin cambiar tu vida — solo entendiéndola mejor.",
    features_title: "6 herramientas. 6 problemas resueltos. 0 excusas.",
    features_desc: "Cada funcionalidad existe porque alguien nos dijo: \u201CNecesito esto y no lo encuentro en ningún lado.\u201D",
    feat1_title: "Tu Mes Entero en Una Sola Pantalla",
    feat1_desc: "Abre la app y ve de inmediato: cuánto ganas, cuánto has gastado, y cuánto te queda — por categoría, al céntimo. Imagina llegar al día 25 y saber, con certeza, que el alquiler, las matrículas y el supermercado están cubiertos. Esa es la sensación.",
    feat2_title: "Impuestos Calculados en Segundos",
    feat2_desc: "Introduce tu salario bruto y, en 2 segundos, ves el neto exacto que llega a tu cuenta — con tablas fiscales 2026 integradas, tasa efectiva y deducciones. Soporte para Portugal, España, Francia y Reino Unido. Nunca más abras ese simulador dudoso que te da un número diferente cada vez.",
    feat3_title: "Entra al Supermercado con Todo Decidido",
    feat3_desc: "Antes de salir de casa, la app te dice: \u201CEsta semana, tus compras salen por ±€47,80.\u201D Creas la lista, ves los precios que registraste, y sabes el total antes de coger el carrito. Sin sorpresas en caja. Control total, compra a compra.",
    feat4_title: "El Presupuesto Familiar, en Tiempo Real",
    feat4_desc: "João añade la factura del gas. María tacha la leche de la lista. Los niños ven que faltan €15 para la excursión del domingo. Todos mirando la misma pantalla, todos remando en la misma dirección — sin discusiones sobre dinero en la cena.",
    feat5_title: "30 Días de Comidas Que Caben en el Presupuesto",
    feat5_desc: "Lunes: sopa + pollo a la plancha. Martes: pasta carbonara. La app planifica 30 días de comidas y genera la lista de compras con costes estimados. ¿Resultado? Menos desperdicio, menos \u201C¿qué cenamos?\u201D y una cuenta del supermercado que por fin tiene sentido.",
    feat6_title: "Un Coach Financiero Que Aprende Contigo",
    feat6_desc: "\u201CMaría, este mes gastaste 23% más en restaurantes. Si cocinas 2× más en casa, ahorras ±€85.\u201D La IA analiza tus patrones reales y da sugerencias concretas — no genéricas. Como tener un asesor financiero en el bolsillo, 24h, que sabe exactamente cómo gastas.",
    screens_title: "5 pantallas. Cero confusión. Control absoluto.",
    screens_desc: "Cada pantalla te da respuestas en segundos — no más preguntas.",
    screen1_title: "Dashboard",
    screen1_desc: "Ingresos, gastos, ahorro y tendencia mensual — todo de un vistazo. Sabes en 3 segundos si el mes va bien o necesitas ajustar.",
    screen2_title: "Supermercado",
    screen2_desc: "Consulta precios de 248+ productos, compara marcas y guarda el historial para saber cuándo un precio sube o baja.",
    screen3_title: "Lista de la Compra",
    screen3_desc: "Compartida con la familia, actualizada al instante. Cada artículo tiene precio estimado — el total aparece antes de salir de casa.",
    screen4_title: "Comidas",
    screen4_desc: "Planifica almuerzo y cena para la semana entera. La lista de ingredientes se genera automáticamente — cero decisiones de último momento.",
    screen5_title: "Coach IA",
    screen5_desc: "Haz preguntas sobre tu presupuesto y recibe respuestas personalizadas. \u201C¿Puedo cenar fuera este sábado?\u201D — el coach sabe la respuesta.",
    cta_title: "El próximo mes no tiene que ser como el último.",
    cta_desc: "Únete a las familias que dejaron de sobrevivir al mes y empezaron a dominarlo. Empieza gratis y sin compromiso. Sin datos enviados a ningún sitio. Solo tú y tu dinero — por fin en paz.",
    cta_button: "Probar Gratis",
    cta_micro: "Sin tarjeta de crédito. Lleva menos de 5 minutos configurar. Tu próximo mes te lo agradecerá.",
    footer_desc: "La app que está cambiando cómo las familias viven el dinero. Hecha en Portugal, con orgullo.",
    footer_app_heading: "App",
    footer_legal_heading: "Legal",
    footer_feat_link: "Funcionalidades",
    footer_screens_link: "Pantallas",
    footer_download_link: "Descargar",
    footer_privacy_link: "Política de Privacidad",
    footer_terms_link: "Términos de Uso",
    footer_copyright: "© 2026 Gestão Mensal. Todos los derechos reservados.",
    footer_made_in: "Hecho con cuidado en Portugal",
    timeline_title: "30 días que le dieron la vuelta a la vida de María",
    timeline_subtitle: "Un mes entero. Desafíos reales. Victorias que lo cambian todo. Sigue cada paso.",
    timeline_intro: "María tiene 34 años, vive en Lisboa con João y dos hijos. Gana €1.400 netos. Cada mes, el dinero parece evaporarse antes del día 20. Esta es la historia del mes en que eso cambió.",
    timeline_day1_title: "\u201CMi dinero desaparece y no sé a dónde\u201D",
    timeline_day1_pain: "Es domingo por la noche. María se sienta en la mesa de la cocina con un montón de recibos y el extracto del banco abierto en el móvil. Intenta hacer cuentas, pero los números no cuadran. Lo cierra todo, frustrada. Mañana es día 1 y ya siente el aprieto.",
    timeline_day1_resolution: "En menos de 10 minutos, introduce sus ingresos y gastos fijos en la app. Por primera vez, ve el mes entero en una pantalla: cuánto entra, cuánto ya está comprometido, y cuánto sobra para el día a día. Respira hondo. Ahora tiene un plan.",
    timeline_day5_title: "\u201CLa factura del gas casi se me escapa — otra vez\u201D",
    timeline_day5_pain: "María recibe un SMS del banco: saldo por debajo de €200. El corazón se le acelera. La factura del gas vence mañana y se le había olvidado. El mismo estrés de cada mes — esa sensación de ir siempre detrás del problema.",
    timeline_day5_resolution: "Pero esta vez, la app ya había enviado un recordatorio ayer. Pagó la factura con calma, sin urgencia, sin miedo. Una alerta simple. Una preocupación menos. El estómago, por primera vez, no se le encogió.",
    timeline_day9_title: "\u201C\u2018¿Qué cenamos?\u2019 — la pregunta que costaba €200 al mes\u201D",
    timeline_day9_pain: "Todos los días, sobre las 18h, la misma conversación: \u201C¿Qué comemos?\u201D Nadie sabe. Nadie decidió. ¿Resultado? Comida a domicilio de última hora o otra ida al supermercado sin lista — y otros €15 que nadie había presupuestado.",
    timeline_day9_resolution: "El plan de comidas de la semana está listo desde el domingo. La lista de compras se generó automáticamente, con cantidades y precios estimados. Entró al supermercado, compró exactamente lo que necesitaba, y salió en 25 minutos. Sin estrés. Sin impulsos. Sin culpa.",
    timeline_day14_title: "\u201CMediado el mes. La verdad duele — pero hay un plan.\u201D",
    timeline_day14_pain: "João abre la app y ve la alerta: ya han gastado el 68% del presupuesto de restaurantes y solo están a mitad de mes. Siente culpa. María siente frustración. El ambiente se tensa.",
    timeline_day14_resolution: "Pero la app no juzga — muestra el impacto y sugiere alternativas. Deciden juntos cocinar este fin de semana. No por castigo, sino porque ven los números y sienten que están eligiendo, no reaccionando. La tensión se disuelve. Trabajan en equipo.",
    timeline_day18_title: "\u201CEntrar al supermercado sin miedo — por primera vez en años\u201D",
    timeline_day18_pain: "Antes, cada ida al supermercado era un ejercicio de ansiedad. ¿Llevar más o menos? ¿Este precio es bueno? ¿Estoy gastando de más? La caja era un momento de verdad que María temía.",
    timeline_day18_resolution: "Hoy, abre la app y ve: lista de 23 productos, total estimado de €47,80. Sabe exactamente qué va a comprar y cuánto va a costar. En la fila de la caja, el total real es €49,20. Diferencia de €1,40. María sonríe. Esto es control.",
    timeline_day25_title: "\u201CAlquiler pagado. Matrículas pagadas. Y aún sobra.\u201D",
    timeline_day25_pain: "El día 25 solía ser el peor día del mes. Alquiler, matrículas del hijo mayor, seguro del coche — todo a la vez. Pasaba la semana anterior sin dormir bien, haciendo cuentas una y otra vez.",
    timeline_day25_resolution: "Esta vez, abre el dashboard y confirma: alquiler cubierto, matrículas cubiertas, seguro cubierto. Quedan €120 para la última semana. No es suerte — es el resultado de un mes entero con un plan. Llama a su madre y, por primera vez, no cuelga pensando en el dinero.",
    timeline_day30_title: "\u201C€180 ahorrados. Cero sacrificio. Una sonrisa enorme.\u201D",
    timeline_day30_pain: "En los últimos años, acabar el mes sin números rojos ya era una victoria. ¿Ahorrar? Parecía cosa de otra gente. De gente que gana más, que tiene menos facturas, que nació con suerte.",
    timeline_day30_resolution: "Y sin embargo, aquí está: €180 ahorrados. Sin recortar lo que les gusta. Sin modo supervivencia. La app muestra una racha de 30 días de hábitos saludables y sugiere crear un fondo de emergencia. María le enseña la pantalla a João. Él sonríe. Ella también. El próximo mes ya no da miedo.",
    faq_title: "Preguntas Frecuentes",
    faq1_q: "¿La app es gratis?",
    faq1_a: "Sí, puedes usar la app gratis con funcionalidades esenciales. Al instalarla, tienes acceso completo durante 21 días para probar todo. Después, decides si continúas gratis o activas un plan.",
    faq2_q: "¿Mis datos están seguros?",
    faq2_a: "Todos los datos se guardan localmente en tu móvil. No enviamos nada a servidores externos. Tú eres el único dueño de tu información financiera.",
    faq3_q: "¿Necesito vincular mi cuenta bancaria?",
    faq3_a: "No. La app funciona con los valores que tú introduces manualmente. Sin acceso al banco, sin riesgo.",
    faq4_q: "¿Funciona para familias o solo para una persona?",
    faq4_a: "Para ambas cosas. Puedes usarla solo o compartir el presupuesto y las listas de compras con quien viva contigo.",
    faq5_q: "¿Las tablas de IRS están actualizadas?",
    faq5_a: "Sí. Usamos las tablas oficiales de retención del IRS publicadas por la Autoridad Tributaria portuguesa, actualizadas para 2026.",
    faq6_q: "¿La app funciona en iOS / iPhone?",
    faq6_a: "De momento, Gestão Mensal está disponible solo para Android. Estamos trabajando en la versión iOS.",
    faq7_q: "¿Necesito tarjeta de crédito para la prueba gratis?",
    faq7_a: "No. La prueba de 21 días es totalmente gratuita y no pide datos de pago. Solo los introduces si decides suscribirte.",
    faq8_q: "¿Puedo cancelar la suscripción en cualquier momento?",
    faq8_a: "Sí. Puedes cancelar cuando quieras, directamente en Google Play. Mantienes el acceso hasta el final del período pagado y luego pasas al plan gratuito.",
    nav_pricing: "Precios",
    pricing_title: "Un plan para cada tipo de familia",
    pricing_desc: "Empieza con 21 días gratis. Sin tarjeta de crédito. Cancela cuando quieras.",
    pricing_toggle_monthly: "Mensual",
    pricing_toggle_yearly: "Anual",
    pricing_save_badge: "Ahorra 37%",
    pricing_trial_banner: "21 días gratis en todos los planes",
    pricing_free_name: "Gratuito",
    pricing_free_price: "€0",
    pricing_free_period: "para siempre",
    pricing_free_desc: "Para quien quiere empezar a organizar sus finanzas con lo esencial.",
    pricing_free_cta: "Empezar Gratis",
    pricing_free_feat1: "Calculadora de presupuesto (8 categorías)",
    pricing_free_feat2: "Registro de gastos (mes actual)",
    pricing_free_feat3: "1 objetivo de ahorro",
    pricing_free_feat4: "Lista de compras (local)",
    pricing_free_feat5: "Anuncios banner",
    pricing_premium_name: "Premium",
    pricing_premium_price_monthly: "€3,99",
    pricing_premium_price_yearly: "€29,99",
    pricing_premium_period_monthly: "/mes",
    pricing_premium_period_yearly: "/año",
    pricing_premium_desc: "Para quien quiere control total sobre su presupuesto y acceso a herramientas inteligentes.",
    pricing_premium_cta: "Empezar Prueba Gratis",
    pricing_premium_popular: "Más Popular",
    pricing_premium_feat1: "Categorías e historial ilimitados",
    pricing_premium_feat2: "Coach Financiero con IA",
    pricing_premium_feat3: "Planificador de comidas + recetas IA",
    pricing_premium_feat4: "Sincronización de lista de compras",
    pricing_premium_feat5: "Exportación PDF/CSV",
    pricing_premium_feat6: "Recordatorios de facturas",
    pricing_premium_feat7: "Sin anuncios",
    pricing_premium_feat8: "Tendencias y gráficos de gastos",
    pricing_premium_feat9: "Objetivos de ahorro ilimitados",
    pricing_premium_feat10: "Gestión de gastos recurrentes",
    pricing_family_name: "Familia",
    pricing_family_price_monthly: "€6,99",
    pricing_family_price_yearly: "€49,99",
    pricing_family_period_monthly: "/mes",
    pricing_family_period_yearly: "/año",
    pricing_family_desc: "Para familias que quieren gestionar todo juntas — presupuesto, compras y comidas.",
    pricing_family_cta: "Empezar Prueba Gratis",
    pricing_family_feat1: "Todo del Premium",
    pricing_family_feat2: "Compartir en familia (hasta 6)",
    pricing_family_feat3: "Simulador de impuestos multipaís",
    pricing_family_feat4: "Índice de estrés + rachas",
    pricing_family_feat5: "Informes de fin de mes",
    pricing_family_feat6: "Dashboard personalizable",
    pricing_family_feat7: "Todos los temas de colores",
    footer_pricing_link: "Precios",
    nav_delete_account: "Eliminar Cuenta",
    delete_title: "Eliminar Cuenta y Datos",
    delete_last_updated: "Última actualización: 14 de marzo de 2026",
    delete_intro: "En Gestão Mensal, respetamos tu derecho a controlar tus datos personales. Esta página explica cómo puedes solicitar la eliminación de tu cuenta y todos los datos asociados.",
    delete_steps_title: "Cómo eliminar tu cuenta",
    delete_step1: "Abre la app Gestão Mensal en tu dispositivo Android.",
    delete_step2: "Ve a Ajustes (icono de engranaje en la esquina superior).",
    delete_step3: "Desplázate hasta abajo y pulsa \"Eliminar cuenta y datos\".",
    delete_step4: "Confirma la eliminación. Tu cuenta y todos los datos serán eliminados permanentemente.",
    delete_alt_title: "Método alternativo: por email",
    delete_alt_desc: "Si no puedes acceder a la app, puedes solicitar la eliminación enviando un email desde la dirección asociada a tu cuenta:",
    delete_data_title: "Datos que se eliminan vs. se retienen",
    delete_data_deleted_title: "Datos eliminados permanentemente (en un plazo de 30 días):",
    delete_data_deleted1: "Datos de la cuenta (email, nombre, preferencias)",
    delete_data_deleted2: "Datos financieros (ingresos, gastos, presupuestos, objetivos de ahorro)",
    delete_data_deleted3: "Listas de compras e historial de precios",
    delete_data_deleted4: "Planes de comidas y preferencias alimentarias",
    delete_data_deleted5: "Historial de interacciones con el Coach Financiero IA",
    delete_data_deleted6: "Datos de sincronización y compartición familiar",
    delete_data_retained_title: "Datos que pueden retenerse:",
    delete_data_retained1: "Registros de transacciones de pago (procesados por Google Play) — retenidos por Google según sus obligaciones legales y fiscales. Gestão Mensal no tiene acceso a estos datos.",
    delete_data_retained2: "Datos anonimizados y agregados que ya no permiten identificar al usuario, utilizados para mejorar el servicio.",
    delete_timeline_title: "Plazos de eliminación",
    delete_timeline1: "La cuenta se desactiva inmediatamente tras la solicitud.",
    delete_timeline2: "Todos los datos personales se eliminan de nuestros servidores en un plazo de 30 días.",
    delete_timeline3: "Los datos locales en tu dispositivo se eliminan al desinstalar la app.",
    delete_subscription_title: "Suscripciones activas",
    delete_subscription_desc: "Eliminar tu cuenta no cancela automáticamente tu suscripción en Google Play. Para evitar cargos futuros, cancela la suscripción antes de eliminar la cuenta: Google Play > Suscripciones > Gestão Mensal > Cancelar.",
    delete_important_title: "Importante",
    delete_important_desc: "La eliminación de la cuenta es permanente e irreversible. Todos los datos se perderán y no podrán recuperarse. Si tienes un plan Premium o Familia, te recomendamos exportar tus datos (PDF/CSV) antes de proceder.",
    delete_contact_title: "¿Preguntas?",
    delete_contact_desc: "Si tienes dudas sobre la eliminación de tu cuenta o tus datos, contáctanos:",
    delete_see_also: "Consulta también nuestra",
    delete_privacy_link: "Política de Privacidad",
    privacy_title: "Política de Privacidad",
    privacy_last_updated: "Última actualización: 14 de marzo de 2026",
    terms_title: "Términos de Uso",
    terms_last_updated: "Última actualización: 14 de marzo de 2026",
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
    hero_badge: "Nouvelle version 2026 — l\u2019app budget #1 faite au Portugal",
    hero_title_line1: "Vous savez exactement où",
    hero_title_line2: "va chaque euro de votre mois",
    hero_subtitle: "Rejoignez les familles qui contrôlent déjà leurs impôts, leurs courses et chaque centime du mois — sans tableurs, sans apps compliquées. Commencez gratuitement, sans engagement.",
    hero_cta_primary: "Essayer Gratuitement",
    hero_cta_secondary: "Découvrez Comment Ça Marche",
    stat1_value: "< 5 min",
    stat1_label: "Pour commencer",
    stat2_value: "180\u20AC",
    stat2_label: "Épargne moy./mois",
    stat3_value: "21 jours",
    stat3_label: "Essai gratuit",
    stat4_value: "100%",
    stat4_label: "Données sur votre tél.",
    mockup_title: "Budget Mensuel",
    mockup_net_label: "Revenu Net",
    mockup_expenses_label: "Dépenses",
    mockup_savings_label: "Épargne",
    mockup_trend_label: "Tendance Mensuelle",
    mockup_label: "Dashboard",
    float1: "+619\u20AC économisés ce mois !",
    float2: "Impôts calculés en 3 secondes",
    float3: "Liste de courses : 47,80\u20AC",
    trust1: "Données 100% sur votre téléphone — elles n\u2019en sortent jamais",
    trust2: "Essai gratuit — sans carte de crédit",
    trust3: "Tables IRS officielles intégrées et à jour",
    trust4: "Faite au Portugal, avec soin et conformité RGPD",
    how_title: "Commencez en 3 étapes simples",
    how_desc: "Du téléchargement à votre premier mois sous contrôle — ça prend moins de temps que de faire un café.",
    how_step1_title: "Téléchargez l\u2019app",
    how_step1_desc: "Disponible sur Google Play. Commencez gratuitement avec toutes les fonctionnalités — sans carte de crédit.",
    how_step2_title: "Configurez en 5 minutes",
    how_step2_desc: "Entrez vos revenus et charges fixes. L\u2019app organise votre mois entier automatiquement.",
    how_step3_title: "Regardez votre mois prendre forme",
    how_step3_desc: "Le tableau de bord montre où va chaque euro. Commencez à épargner sans changer de vie — juste en la comprenant mieux.",
    features_title: "6 outils. 6 problèmes résolus. 0 excuse.",
    features_desc: "Chaque fonctionnalité existe parce que quelqu\u2019un nous a dit : \u201CJ\u2019ai besoin de ça et je ne le trouve nulle part.\u201D",
    feat1_title: "Tout Votre Mois sur Un Seul Écran",
    feat1_desc: "Ouvrez l\u2019app et voyez instantanément : combien vous gagnez, combien vous avez dépensé, et combien il reste — par catégorie, au centime près. Imaginez arriver au 25 du mois en sachant avec certitude que le loyer, les frais de scolarité et les courses sont couverts. C\u2019est cette sensation.",
    feat2_title: "Impôts Calculés en Secondes",
    feat2_desc: "Entrez votre salaire brut et, en 2 secondes, voyez le net exact qui arrive sur votre compte — avec les tables fiscales 2026 intégrées, taux effectif et déductions. Support pour le Portugal, l\u2019Espagne, la France et le Royaume-Uni. Plus jamais ouvrir ce simulateur douteux qui donne un chiffre différent à chaque fois.",
    feat3_title: "Entrez au Supermarché avec Tout Décidé",
    feat3_desc: "Avant de partir, l\u2019app vous dit : \u201CCette semaine, vos courses reviennent à \u00b147,80\u20AC.\u201D Créez la liste, consultez les prix enregistrés, et connaissez le total avant de prendre un chariot. Zéro surprise en caisse. Contrôle total, achat par achat.",
    feat4_title: "Le Budget Familial, en Temps Réel",
    feat4_desc: "João ajoute la facture de gaz. Maria raye le lait de la liste. Les enfants voient qu\u2019il reste 15\u20AC pour la sortie de dimanche. Tout le monde regarde le même écran, tout le monde rame dans le même sens — fini les disputes sur l\u2019argent au dîner.",
    feat5_title: "30 Jours de Repas Qui Respectent le Budget",
    feat5_desc: "Lundi : soupe + poulet grillé. Mardi : carbonara. L\u2019app planifie 30 jours de repas et génère la liste de courses avec les coûts estimés. Résultat ? Moins de gaspillage, moins de \u201Con mange quoi ?\u201D et une note de supermarché qui a enfin du sens.",
    feat6_title: "Un Coach Financier Qui Apprend Avec Vous",
    feat6_desc: "\u201CMaria, ce mois-ci vous avez dépensé 23% de plus en restaurants. En cuisinant 2\u00d7 plus à la maison, vous économisez \u00b185\u20AC.\u201D L\u2019IA analyse vos schémas réels et donne des suggestions concrètes — pas génériques. Comme avoir un conseiller financier dans la poche, 24h/24, qui sait exactement comment vous dépensez.",
    screens_title: "5 écrans. Zéro confusion. Contrôle absolu.",
    screens_desc: "Chaque écran vous donne des réponses en secondes — pas plus de questions.",
    screen1_title: "Tableau de bord",
    screen1_desc: "Revenus, dépenses, épargne et tendance mensuelle — tout d\u2019un coup d\u2019œil. Sachez en 3 secondes si le mois est sur la bonne voie ou s\u2019il faut ajuster.",
    screen2_title: "Supermarché",
    screen2_desc: "Consultez les prix de 248+ produits, comparez les marques et suivez l\u2019historique pour savoir quand un prix monte ou baisse.",
    screen3_title: "Liste de Courses",
    screen3_desc: "Partagée en famille, mise à jour instantanément. Chaque article a un prix estimé — le total s\u2019affiche avant de quitter la maison.",
    screen4_title: "Repas",
    screen4_desc: "Planifiez déjeuner et dîner pour toute la semaine. La liste d\u2019ingrédients est générée automatiquement — zéro décision de dernière minute.",
    screen5_title: "Coach IA",
    screen5_desc: "Posez des questions sur votre budget et recevez des réponses personnalisées. \u201CPuis-je dîner dehors ce samedi ?\u201D — le coach connaît la réponse.",
    cta_title: "Le mois prochain n\u2019a pas à ressembler au dernier.",
    cta_desc: "Rejoignez les familles qui ont arrêté de survivre au mois et ont commencé à le maîtriser. Commencez gratuitement, sans engagement. Sans données envoyées nulle part. Juste vous et votre argent — enfin en paix.",
    cta_button: "Essayer Gratuitement",
    cta_micro: "Sans carte de crédit. Moins de 5 minutes pour tout configurer. Votre prochain mois vous remerciera.",
    footer_desc: "L\u2019app qui change la façon dont les familles vivent l\u2019argent. Faite au Portugal, avec fierté.",
    footer_app_heading: "App",
    footer_legal_heading: "Légal",
    footer_feat_link: "Fonctionnalités",
    footer_screens_link: "Écrans",
    footer_download_link: "Télécharger",
    footer_privacy_link: "Politique de Confidentialité",
    footer_terms_link: "Conditions d'Utilisation",
    footer_copyright: "© 2026 Gestão Mensal. Tous droits réservés.",
    footer_made_in: "Fait avec soin au Portugal",
    timeline_title: "30 jours qui ont bouleversé la vie de Maria",
    timeline_subtitle: "Un mois entier. Des défis réels. Des victoires qui changent tout. Suivez chaque étape.",
    timeline_intro: "Maria a 34 ans, vit à Lisbonne avec João et deux enfants. Elle gagne 1\u2009400\u20AC nets. Chaque mois, l\u2019argent semble s\u2019évaporer avant le 20. Voici l\u2019histoire du mois où tout a changé.",
    timeline_day1_title: "\u201CMon argent disparaît et je ne sais pas où\u201D",
    timeline_day1_pain: "C\u2019est dimanche soir. Maria s\u2019assoit à la table de la cuisine avec une pile de reçus et son relevé bancaire ouvert sur le téléphone. Elle essaie de faire les comptes, mais les chiffres ne collent pas. Elle ferme tout, frustrée. Demain c\u2019est le 1er et elle sent déjà la pression.",
    timeline_day1_resolution: "En moins de 10 minutes, elle saisit ses revenus et charges fixes dans l\u2019app. Pour la première fois, elle voit le mois entier sur un écran : ce qui entre, ce qui est déjà engagé, et ce qui reste pour le quotidien. Elle respire. Maintenant, elle a un plan.",
    timeline_day5_title: "\u201CLa facture de gaz a failli m\u2019échapper — encore\u201D",
    timeline_day5_pain: "Maria reçoit un SMS de la banque : solde en dessous de 200\u20AC. Son cœur s\u2019accélère. La facture de gaz est due demain et elle avait oublié. Le même stress chaque mois — cette sensation de toujours courir après les problèmes.",
    timeline_day5_resolution: "Mais cette fois, l\u2019app avait déjà envoyé un rappel hier. Elle a payé calmement, sans urgence, sans peur. Une alerte simple. Un souci de moins. Pour la première fois, son estomac ne s\u2019est pas noué.",
    timeline_day9_title: "\u201C\u2018On mange quoi ?\u2019 — la question qui coûtait 200\u20AC par mois\u201D",
    timeline_day9_pain: "Tous les jours vers 18h, la même conversation : \u201COn mange quoi ?\u201D Personne ne sait. Personne n\u2019a décidé. Résultat ? Livraison de dernière minute ou un tour au supermarché sans liste — et 15\u20AC de plus que personne n\u2019avait prévus.",
    timeline_day9_resolution: "Le planning repas de la semaine est prêt depuis dimanche. La liste de courses a été générée automatiquement, avec quantités et prix estimés. Elle est entrée au supermarché, a acheté exactement ce qu\u2019il fallait, et en est sortie en 25 minutes. Sans stress. Sans achats impulsifs. Sans culpabilité.",
    timeline_day14_title: "\u201CMi-mois. La vérité fait mal — mais il y a un plan.\u201D",
    timeline_day14_pain: "João ouvre l\u2019app et voit l\u2019alerte : ils ont déjà utilisé 68% du budget restaurants et on n\u2019est qu\u2019à mi-mois. Culpabilité. Maria ressent de la frustration. L\u2019ambiance se tend.",
    timeline_day14_resolution: "Mais l\u2019app ne juge pas — elle montre l\u2019impact et suggère des alternatives. Ils décident ensemble de cuisiner ce week-end. Pas par punition, mais parce qu\u2019ils voient les chiffres et sentent qu\u2019ils choisissent, au lieu de subir. La tension se dissipe. Ils travaillent en équipe.",
    timeline_day18_title: "\u201CEntrer au supermarché sans peur — pour la première fois depuis des années\u201D",
    timeline_day18_pain: "Avant, chaque course au supermarché était un exercice d\u2019anxiété. Prendre plus ou moins ? Ce prix est-il bon ? Est-ce que je dépense trop ? La caisse était un moment de vérité que Maria redoutait.",
    timeline_day18_resolution: "Aujourd\u2019hui, elle ouvre l\u2019app et voit : liste de 23 produits, total estimé 47,80\u20AC. Elle sait exactement quoi acheter et combien ça va coûter. En caisse, le total réel est 49,20\u20AC. Différence : 1,40\u20AC. Maria sourit. Ça, c\u2019est le contrôle.",
    timeline_day25_title: "\u201CLoyer payé. Scolarité payée. Et il reste de l\u2019argent.\u201D",
    timeline_day25_pain: "Le 25 était autrefois le pire jour du mois. Loyer, frais de scolarité de l\u2019aîné, assurance auto — tout en même temps. Elle passait la semaine précédente à mal dormir, à refaire les calculs sans cesse.",
    timeline_day25_resolution: "Cette fois, elle ouvre le tableau de bord et confirme : loyer couvert, scolarité couverte, assurance couverte. Il reste 120\u20AC pour la dernière semaine. Ce n\u2019est pas de la chance — c\u2019est le résultat d\u2019un mois entier avec un plan. Elle appelle sa mère et, pour la première fois, ne raccroche pas en pensant à l\u2019argent.",
    timeline_day30_title: "\u201C180\u20AC économisés. Zéro sacrifice. Un immense sourire.\u201D",
    timeline_day30_pain: "Ces dernières années, finir le mois sans être dans le rouge était déjà une victoire. Épargner ? Ça semblait réservé aux autres. Ceux qui gagnent plus, qui ont moins de factures, qui sont nés avec de la chance.",
    timeline_day30_resolution: "Et pourtant, voilà : 180\u20AC économisés. Sans renoncer à ce qu\u2019ils aiment. Sans mode survie. L\u2019app montre une série de 30 jours d\u2019habitudes saines et suggère de créer un fonds d\u2019urgence. Maria montre l\u2019écran à João. Il sourit. Elle aussi. Le mois prochain ne fait plus peur.",
    faq_title: "Questions Fréquentes",
    faq1_q: "L\u2019app est-elle gratuite ?",
    faq1_a: "Oui, vous pouvez utiliser l\u2019app gratuitement avec les fonctionnalités essentielles. À l\u2019installation, vous avez accès à tout pendant 21 jours. Ensuite, vous décidez de rester en gratuit ou d\u2019activer un plan.",
    faq2_q: "Mes données sont-elles en sécurité ?",
    faq2_a: "Toutes les données restent stockées localement sur votre téléphone. Nous n\u2019envoyons rien à des serveurs externes. Vous êtes le seul propriétaire de vos informations financières.",
    faq3_q: "Dois-je lier mon compte bancaire ?",
    faq3_a: "Non. L\u2019app fonctionne avec les valeurs que vous saisissez manuellement. Pas d\u2019accès bancaire, pas de risque.",
    faq4_q: "Ça fonctionne pour les familles ou seulement pour une personne ?",
    faq4_a: "Les deux. Vous pouvez l\u2019utiliser seul ou partager le budget et les listes de courses avec votre foyer.",
    faq5_q: "Les tables d\u2019IRS sont-elles à jour ?",
    faq5_a: "Oui. Nous utilisons les tables officielles de retenue à la source publiées par l\u2019Autorité Fiscale portugaise, mises à jour pour 2026.",
    faq6_q: "L\u2019app fonctionne sur iOS / iPhone ?",
    faq6_a: "Pour le moment, Gestão Mensal est disponible uniquement sur Android. Nous travaillons sur la version iOS.",
    faq7_q: "Faut-il une carte de crédit pour l\u2019essai gratuit ?",
    faq7_a: "Non. L\u2019essai de 21 jours est entièrement gratuit et ne demande aucune information de paiement. Vous ne les saisissez que si vous décidez de vous abonner.",
    faq8_q: "Puis-je annuler mon abonnement à tout moment ?",
    faq8_a: "Oui. Vous pouvez annuler quand vous voulez, directement via Google Play. Vous gardez l\u2019accès jusqu\u2019à la fin de la période payée, puis vous passez au plan gratuit.",
    nav_pricing: "Tarifs",
    pricing_title: "Un plan pour chaque type de famille",
    pricing_desc: "Commencez avec 21 jours gratuits. Sans carte de crédit. Annulez quand vous voulez.",
    pricing_toggle_monthly: "Mensuel",
    pricing_toggle_yearly: "Annuel",
    pricing_save_badge: "Économisez 37%",
    pricing_trial_banner: "21 jours gratuits sur tous les plans",
    pricing_free_name: "Gratuit",
    pricing_free_price: "0\u20AC",
    pricing_free_period: "pour toujours",
    pricing_free_desc: "Pour ceux qui veulent commencer à organiser leurs finances avec l\u2019essentiel.",
    pricing_free_cta: "Commencer Gratuitement",
    pricing_free_feat1: "Calculateur de budget (8 catégories)",
    pricing_free_feat2: "Suivi des dépenses (mois en cours)",
    pricing_free_feat3: "1 objectif d\u2019épargne",
    pricing_free_feat4: "Liste de courses (locale)",
    pricing_free_feat5: "Publicités bannière",
    pricing_premium_name: "Premium",
    pricing_premium_price_monthly: "3,99\u20AC",
    pricing_premium_price_yearly: "29,99\u20AC",
    pricing_premium_period_monthly: "/mois",
    pricing_premium_period_yearly: "/an",
    pricing_premium_desc: "Pour ceux qui veulent un contrôle total sur leur budget et des outils intelligents.",
    pricing_premium_cta: "Essai Gratuit",
    pricing_premium_popular: "Le Plus Populaire",
    pricing_premium_feat1: "Catégories et historique illimités",
    pricing_premium_feat2: "Coach Financier IA",
    pricing_premium_feat3: "Planificateur de repas + recettes IA",
    pricing_premium_feat4: "Synchronisation liste de courses",
    pricing_premium_feat5: "Export PDF/CSV",
    pricing_premium_feat6: "Rappels de factures",
    pricing_premium_feat7: "Sans publicités",
    pricing_premium_feat8: "Tendances et graphiques de dépenses",
    pricing_premium_feat9: "Objectifs d\u2019épargne illimités",
    pricing_premium_feat10: "Gestion des dépenses récurrentes",
    pricing_family_name: "Famille",
    pricing_family_price_monthly: "6,99\u20AC",
    pricing_family_price_yearly: "49,99\u20AC",
    pricing_family_period_monthly: "/mois",
    pricing_family_period_yearly: "/an",
    pricing_family_desc: "Pour les familles qui veulent tout gérer ensemble — budget, courses et repas.",
    pricing_family_cta: "Essai Gratuit",
    pricing_family_feat1: "Tout du Premium",
    pricing_family_feat2: "Partage familial (jusqu\u2019à 6)",
    pricing_family_feat3: "Simulateur fiscal multi-pays",
    pricing_family_feat4: "Indice de stress + séries",
    pricing_family_feat5: "Rapports de fin de mois",
    pricing_family_feat6: "Tableau de bord personnalisable",
    pricing_family_feat7: "Tous les thèmes de couleurs",
    footer_pricing_link: "Tarifs",
    nav_delete_account: "Supprimer le Compte",
    delete_title: "Supprimer le Compte et les Données",
    delete_last_updated: "Dernière mise à jour : 14 mars 2026",
    delete_intro: "Chez Gestão Mensal, nous respectons votre droit de contrôler vos données personnelles. Cette page explique comment demander la suppression de votre compte et de toutes les données associées.",
    delete_steps_title: "Comment supprimer votre compte",
    delete_step1: "Ouvrez l\u2019app Gestão Mensal sur votre appareil Android.",
    delete_step2: "Allez dans Paramètres (icône d\u2019engrenage en haut).",
    delete_step3: "Faites défiler vers le bas et appuyez sur \u00ab Supprimer le compte et les données \u00bb.",
    delete_step4: "Confirmez la suppression. Votre compte et toutes les données seront définitivement supprimés.",
    delete_alt_title: "Méthode alternative : par email",
    delete_alt_desc: "Si vous ne pouvez pas accéder à l\u2019app, vous pouvez demander la suppression en envoyant un email depuis l\u2019adresse associée à votre compte :",
    delete_data_title: "Données supprimées vs. conservées",
    delete_data_deleted_title: "Données supprimées définitivement (sous 30 jours) :",
    delete_data_deleted1: "Données du compte (email, nom, préférences)",
    delete_data_deleted2: "Données financières (revenus, dépenses, budgets, objectifs d\u2019épargne)",
    delete_data_deleted3: "Listes de courses et historique des prix",
    delete_data_deleted4: "Plans de repas et préférences alimentaires",
    delete_data_deleted5: "Historique des interactions avec le Coach Financier IA",
    delete_data_deleted6: "Données de synchronisation et de partage familial",
    delete_data_retained_title: "Données pouvant être conservées :",
    delete_data_retained1: "Enregistrements de transactions de paiement (traités par Google Play) — conservés par Google conformément à leurs obligations légales et fiscales. Gestão Mensal n\u2019a pas accès à ces données.",
    delete_data_retained2: "Données anonymisées et agrégées ne permettant plus l\u2019identification de l\u2019utilisateur, utilisées pour améliorer le service.",
    delete_timeline_title: "Délais de suppression",
    delete_timeline1: "Le compte est désactivé immédiatement après la demande.",
    delete_timeline2: "Toutes les données personnelles sont supprimées de nos serveurs sous 30 jours.",
    delete_timeline3: "Les données locales sur votre appareil sont supprimées lorsque vous désinstallez l\u2019app.",
    delete_subscription_title: "Abonnements actifs",
    delete_subscription_desc: "La suppression de votre compte n\u2019annule pas automatiquement votre abonnement Google Play. Pour éviter des frais futurs, annulez votre abonnement avant de supprimer votre compte : Google Play > Abonnements > Gestão Mensal > Annuler.",
    delete_important_title: "Important",
    delete_important_desc: "La suppression du compte est permanente et irréversible. Toutes les données seront perdues et ne pourront pas être récupérées. Si vous avez un plan Premium ou Famille, nous vous recommandons d\u2019exporter vos données (PDF/CSV) avant de procéder.",
    delete_contact_title: "Des questions ?",
    delete_contact_desc: "Si vous avez des questions sur la suppression de votre compte ou de vos données, contactez-nous :",
    delete_see_also: "Consultez également notre",
    delete_privacy_link: "Politique de Confidentialité",
    privacy_title: "Politique de Confidentialité",
    privacy_last_updated: "Dernière mise à jour : 14 mars 2026",
    terms_title: "Conditions d'Utilisation",
    terms_last_updated: "Dernière mise à jour : 14 mars 2026",
  },
};
