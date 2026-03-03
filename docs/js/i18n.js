(function () {
  'use strict';

  var LOCALE_KEY = 'gestao_mensal_locale';

  var SUPPORTED = ['pt', 'en', 'es', 'fr'];

  var translations = {
    pt: {
      skip_link: 'Saltar para o conteúdo',
      nav_home: 'Início',
      nav_features: 'Funcionalidades',
      nav_screens: 'Ecrãs',
      nav_privacy: 'Privacidade',
      nav_terms: 'Termos',
      nav_theme_aria: 'Alternar modo escuro',
      nav_lang_aria: 'Idioma',
      hero_badge: 'Disponível para Android',
      hero_title: 'O seu orçamento mensal,<br/><span>simples e inteligente</span>',
      hero_subtitle: 'Planeie, controle e otimize as finanças da sua família. Com cálculo automático de IRS, planeamento de refeições e coach financeiro com IA.',
      hero_cta_primary: 'Disponível na Google Play',
      hero_cta_secondary: 'Saber Mais',
      stat_features_label: 'Funcionalidades',
      stat_screens_label: 'Ecrãs',
      stat_languages_label: 'Idiomas',
      stat_free_label: 'Gratuita',
      mockup_title: 'Orçamento Mensal',
      mockup_net_label: 'Rendimento Líquido',
      mockup_expenses_label: 'Despesas',
      mockup_savings_label: 'Poupança',
      mockup_trend_label: 'Tendência Mensal',
      mockup_label: 'Dashboard',
      float1: 'Poupança: +€619',
      float2: 'Despesas no limite',
      float3: 'Orçamento seguro',
      trust1: 'Dados no dispositivo',
      trust2: 'Sem anúncios',
      trust3: '100% gratuita',
      trust4: 'RGPD compliant',
      features_title: 'Tudo o que precisa num só lugar',
      features_desc: 'Funcionalidades desenhadas para simplificar a gestão financeira da sua família.',
      feat1_title: 'Orçamento Inteligente',
      feat1_desc: 'Planeie receitas e despesas mensais com categorias personalizáveis. Acompanhe despesas reais vs. planeadas em tempo real.',
      feat2_title: 'Cálculo de IRS Automático',
      feat2_desc: 'Tabelas de IRS portuguesas integradas. Saiba exatamente o rendimento líquido mensal com base no seu escalão.',
      feat3_title: 'Lista de Compras',
      feat3_desc: 'Crie e gira listas de compras com preços reais do supermercado. Sincronização em tempo real entre dispositivos.',
      feat4_title: 'Gestão Familiar',
      feat4_desc: 'Partilhe o orçamento com o agregado familiar. Cada membro pode contribuir e visualizar as finanças do lar.',
      feat5_title: 'Planeamento de Refeições',
      feat5_desc: 'Planeie 30 dias de refeições dentro do orçamento alimentar. Receitas otimizadas com ingredientes agrupados e custos calculados.',
      feat6_title: 'Coach Financeiro com IA',
      feat6_desc: 'Receba conselhos financeiros personalizados baseados nos seus padrões de despesa. Análise inteligente das suas finanças.',
      screens_title: '5 Ecrãs, controlo total',
      screens_desc: 'Cada ecrã foi desenhado para tornar a gestão financeira simples e intuitiva.',
      screen1_title: 'Dashboard',
      screen1_desc: 'Visão geral do orçamento, tendências e metas de poupança.',
      screen2_title: 'Supermercado',
      screen2_desc: 'Catálogo de produtos com preços e favoritos.',
      screen3_title: 'Lista de Compras',
      screen3_desc: 'Listas partilhadas com sincronização em tempo real.',
      screen4_title: 'Refeições',
      screen4_desc: 'Planeie refeições semanais dentro do orçamento alimentar.',
      screen5_title: 'Coach IA',
      screen5_desc: 'Conselhos financeiros inteligentes e personalizados.',
      cta_title: 'Tome o controlo das suas finanças',
      cta_desc: 'Descarregue a Gestão Mensal e comece a poupar com a app mais completa para famílias portuguesas.',
      cta_button: 'Disponível na Google Play',
      footer_desc: 'A app de orçamento mensal mais completa para famílias portuguesas.',
      footer_app_heading: 'App',
      footer_legal_heading: 'Legal',
      footer_feat_link: 'Funcionalidades',
      footer_screens_link: 'Ecrãs',
      footer_download_link: 'Descarregar',
      footer_privacy_link: 'Política de Privacidade',
      footer_terms_link: 'Termos de Utilização',
      footer_copyright: '© 2026 Gestão Mensal. Todos os direitos reservados.',
      footer_made_in: 'Feito com cuidado em Portugal',
    },

    en: {
      skip_link: 'Skip to content',
      nav_home: 'Home',
      nav_features: 'Features',
      nav_screens: 'Screens',
      nav_privacy: 'Privacy',
      nav_terms: 'Terms',
      nav_theme_aria: 'Toggle dark mode',
      nav_lang_aria: 'Language',
      hero_badge: 'Available on Android',
      hero_title: 'Your monthly budget,<br/><span>simple and smart</span>',
      hero_subtitle: 'Plan, track and optimise your family finances. With automatic tax calculation, meal planning and an AI financial coach.',
      hero_cta_primary: 'Available on Google Play',
      hero_cta_secondary: 'Learn More',
      stat_features_label: 'Features',
      stat_screens_label: 'Screens',
      stat_languages_label: 'Languages',
      stat_free_label: 'Free',
      mockup_title: 'Monthly Budget',
      mockup_net_label: 'Net Income',
      mockup_expenses_label: 'Expenses',
      mockup_savings_label: 'Savings',
      mockup_trend_label: 'Monthly Trend',
      mockup_label: 'Dashboard',
      float1: 'Savings: +€619',
      float2: 'Expenses on track',
      float3: 'Budget secure',
      trust1: 'Data on device',
      trust2: 'No ads',
      trust3: '100% free',
      trust4: 'GDPR compliant',
      features_title: 'Everything you need in one place',
      features_desc: 'Features designed to simplify your family\'s financial management.',
      feat1_title: 'Smart Budgeting',
      feat1_desc: 'Plan monthly income and expenses with customisable categories. Track actual vs. planned spending in real time.',
      feat2_title: 'Automatic Tax Calculation',
      feat2_desc: 'Portuguese IRS tax tables built in. Know your exact monthly net income based on your tax bracket.',
      feat3_title: 'Shopping List',
      feat3_desc: 'Create and manage shopping lists with real supermarket prices. Real-time synchronisation across devices.',
      feat4_title: 'Family Management',
      feat4_desc: 'Share the budget with your household. Each member can contribute and view the family finances.',
      feat5_title: 'Meal Planning',
      feat5_desc: 'Plan 30 days of meals within your food budget. Optimised recipes with grouped ingredients and calculated costs.',
      feat6_title: 'AI Financial Coach',
      feat6_desc: 'Receive personalised financial advice based on your spending patterns. Intelligent analysis of your finances.',
      screens_title: '5 Screens, total control',
      screens_desc: 'Each screen was designed to make financial management simple and intuitive.',
      screen1_title: 'Dashboard',
      screen1_desc: 'Budget overview, trends and savings goals.',
      screen2_title: 'Supermarket',
      screen2_desc: 'Product catalogue with prices and favourites.',
      screen3_title: 'Shopping List',
      screen3_desc: 'Shared lists with real-time synchronisation.',
      screen4_title: 'Meals',
      screen4_desc: 'Plan weekly meals within your food budget.',
      screen5_title: 'AI Coach',
      screen5_desc: 'Smart and personalised financial advice.',
      cta_title: 'Take control of your finances',
      cta_desc: 'Download Gestão Mensal and start saving with the most complete app for families.',
      cta_button: 'Available on Google Play',
      footer_desc: 'The most complete monthly budget app for families.',
      footer_app_heading: 'App',
      footer_legal_heading: 'Legal',
      footer_feat_link: 'Features',
      footer_screens_link: 'Screens',
      footer_download_link: 'Download',
      footer_privacy_link: 'Privacy Policy',
      footer_terms_link: 'Terms of Use',
      footer_copyright: '© 2026 Gestão Mensal. All rights reserved.',
      footer_made_in: 'Made with care in Portugal',
    },

    es: {
      skip_link: 'Saltar al contenido',
      nav_home: 'Inicio',
      nav_features: 'Funcionalidades',
      nav_screens: 'Pantallas',
      nav_privacy: 'Privacidad',
      nav_terms: 'Términos',
      nav_theme_aria: 'Alternar modo oscuro',
      nav_lang_aria: 'Idioma',
      hero_badge: 'Disponible en Android',
      hero_title: 'Tu presupuesto mensual,<br/><span>simple e inteligente</span>',
      hero_subtitle: 'Planifica, controla y optimiza las finanzas de tu familia. Con cálculo automático de impuestos, planificación de comidas y coach financiero con IA.',
      hero_cta_primary: 'Disponible en Google Play',
      hero_cta_secondary: 'Saber más',
      stat_features_label: 'Funcionalidades',
      stat_screens_label: 'Pantallas',
      stat_languages_label: 'Idiomas',
      stat_free_label: 'Gratuita',
      mockup_title: 'Presupuesto Mensual',
      mockup_net_label: 'Ingreso Neto',
      mockup_expenses_label: 'Gastos',
      mockup_savings_label: 'Ahorros',
      mockup_trend_label: 'Tendencia Mensual',
      mockup_label: 'Dashboard',
      float1: 'Ahorros: +€619',
      float2: 'Gastos bajo control',
      float3: 'Presupuesto seguro',
      trust1: 'Datos en el dispositivo',
      trust2: 'Sin anuncios',
      trust3: '100% gratuita',
      trust4: 'RGPD compliant',
      features_title: 'Todo lo que necesitas en un solo lugar',
      features_desc: 'Funcionalidades diseñadas para simplificar la gestión financiera de tu familia.',
      feat1_title: 'Presupuesto Inteligente',
      feat1_desc: 'Planifica ingresos y gastos mensuales con categorías personalizables. Controla gastos reales vs. planificados en tiempo real.',
      feat2_title: 'Cálculo de Impuestos Automático',
      feat2_desc: 'Tablas de IRS portuguesas integradas. Conoce exactamente tu ingreso neto mensual según tu tramo.',
      feat3_title: 'Lista de la Compra',
      feat3_desc: 'Crea y gestiona listas de la compra con precios reales del supermercado. Sincronización en tiempo real entre dispositivos.',
      feat4_title: 'Gestión Familiar',
      feat4_desc: 'Comparte el presupuesto con tu hogar. Cada miembro puede contribuir y ver las finanzas del hogar.',
      feat5_title: 'Planificación de Comidas',
      feat5_desc: 'Planifica 30 días de comidas dentro de tu presupuesto alimentario. Recetas optimizadas con ingredientes agrupados y costes calculados.',
      feat6_title: 'Coach Financiero con IA',
      feat6_desc: 'Recibe consejos financieros personalizados basados en tus patrones de gasto. Análisis inteligente de tus finanzas.',
      screens_title: '5 Pantallas, control total',
      screens_desc: 'Cada pantalla fue diseñada para hacer la gestión financiera simple e intuitiva.',
      screen1_title: 'Dashboard',
      screen1_desc: 'Visión general del presupuesto, tendencias y metas de ahorro.',
      screen2_title: 'Supermercado',
      screen2_desc: 'Catálogo de productos con precios y favoritos.',
      screen3_title: 'Lista de la Compra',
      screen3_desc: 'Listas compartidas con sincronización en tiempo real.',
      screen4_title: 'Comidas',
      screen4_desc: 'Planifica comidas semanales dentro del presupuesto alimentario.',
      screen5_title: 'Coach IA',
      screen5_desc: 'Consejos financieros inteligentes y personalizados.',
      cta_title: 'Toma el control de tus finanzas',
      cta_desc: 'Descarga Gestão Mensal y empieza a ahorrar con la app más completa para familias.',
      cta_button: 'Disponible en Google Play',
      footer_desc: 'La app de presupuesto mensual más completa para familias.',
      footer_app_heading: 'App',
      footer_legal_heading: 'Legal',
      footer_feat_link: 'Funcionalidades',
      footer_screens_link: 'Pantallas',
      footer_download_link: 'Descargar',
      footer_privacy_link: 'Política de Privacidad',
      footer_terms_link: 'Términos de Uso',
      footer_copyright: '© 2026 Gestão Mensal. Todos los derechos reservados.',
      footer_made_in: 'Hecho con cuidado en Portugal',
    },

    fr: {
      skip_link: 'Aller au contenu',
      nav_home: 'Accueil',
      nav_features: 'Fonctionnalités',
      nav_screens: 'Écrans',
      nav_privacy: 'Confidentialité',
      nav_terms: 'Conditions',
      nav_theme_aria: 'Basculer le mode sombre',
      nav_lang_aria: 'Langue',
      hero_badge: 'Disponible sur Android',
      hero_title: 'Votre budget mensuel,<br/><span>simple et intelligent</span>',
      hero_subtitle: 'Planifiez, contrôlez et optimisez les finances de votre famille. Avec calcul automatique des impôts, planification des repas et coach financier IA.',
      hero_cta_primary: 'Disponible sur Google Play',
      hero_cta_secondary: 'En savoir plus',
      stat_features_label: 'Fonctionnalités',
      stat_screens_label: 'Écrans',
      stat_languages_label: 'Langues',
      stat_free_label: 'Gratuite',
      mockup_title: 'Budget Mensuel',
      mockup_net_label: 'Revenu Net',
      mockup_expenses_label: 'Dépenses',
      mockup_savings_label: 'Épargne',
      mockup_trend_label: 'Tendance Mensuelle',
      mockup_label: 'Dashboard',
      float1: 'Épargne : +€619',
      float2: 'Dépenses maîtrisées',
      float3: 'Budget sécurisé',
      trust1: 'Données sur l\'appareil',
      trust2: 'Sans publicités',
      trust3: '100% gratuite',
      trust4: 'Conforme RGPD',
      features_title: 'Tout ce dont vous avez besoin en un seul endroit',
      features_desc: 'Des fonctionnalités conçues pour simplifier la gestion financière de votre famille.',
      feat1_title: 'Budget Intelligent',
      feat1_desc: 'Planifiez vos revenus et dépenses mensuels avec des catégories personnalisables. Suivez les dépenses réelles vs. planifiées en temps réel.',
      feat2_title: 'Calcul d\'Impôts Automatique',
      feat2_desc: 'Tables IRS portugaises intégrées. Connaissez exactement votre revenu net mensuel selon votre tranche d\'imposition.',
      feat3_title: 'Liste de Courses',
      feat3_desc: 'Créez et gérez des listes de courses avec les prix réels du supermarché. Synchronisation en temps réel entre appareils.',
      feat4_title: 'Gestion Familiale',
      feat4_desc: 'Partagez le budget avec votre foyer. Chaque membre peut contribuer et consulter les finances du ménage.',
      feat5_title: 'Planification des Repas',
      feat5_desc: 'Planifiez 30 jours de repas dans le cadre de votre budget alimentaire. Recettes optimisées avec ingrédients regroupés et coûts calculés.',
      feat6_title: 'Coach Financier IA',
      feat6_desc: 'Recevez des conseils financiers personnalisés basés sur vos habitudes de dépense. Analyse intelligente de vos finances.',
      screens_title: '5 Écrans, contrôle total',
      screens_desc: 'Chaque écran a été conçu pour rendre la gestion financière simple et intuitive.',
      screen1_title: 'Tableau de bord',
      screen1_desc: 'Vue d\'ensemble du budget, tendances et objectifs d\'épargne.',
      screen2_title: 'Supermarché',
      screen2_desc: 'Catalogue de produits avec prix et favoris.',
      screen3_title: 'Liste de Courses',
      screen3_desc: 'Listes partagées avec synchronisation en temps réel.',
      screen4_title: 'Repas',
      screen4_desc: 'Planifiez les repas hebdomadaires dans le budget alimentaire.',
      screen5_title: 'Coach IA',
      screen5_desc: 'Conseils financiers intelligents et personnalisés.',
      cta_title: 'Prenez le contrôle de vos finances',
      cta_desc: 'Téléchargez Gestão Mensal et commencez à économiser avec l\'app la plus complète pour les familles.',
      cta_button: 'Disponible sur Google Play',
      footer_desc: 'L\'app de budget mensuel la plus complète pour les familles.',
      footer_app_heading: 'App',
      footer_legal_heading: 'Légal',
      footer_feat_link: 'Fonctionnalités',
      footer_screens_link: 'Écrans',
      footer_download_link: 'Télécharger',
      footer_privacy_link: 'Politique de Confidentialité',
      footer_terms_link: 'Conditions d\'Utilisation',
      footer_copyright: '© 2026 Gestão Mensal. Tous droits réservés.',
      footer_made_in: 'Fait avec soin au Portugal',
    }
  };

  function getLocale() {
    try {
      var saved = localStorage.getItem(LOCALE_KEY);
      if (saved && SUPPORTED.indexOf(saved) !== -1) return saved;
    } catch (e) { /* ignore */ }
    var lang = (navigator.language || 'pt').slice(0, 2).toLowerCase();
    return SUPPORTED.indexOf(lang) !== -1 ? lang : 'pt';
  }

  function saveLocale(locale) {
    try { localStorage.setItem(LOCALE_KEY, locale); } catch (e) { /* ignore */ }
  }

  function applyTranslations(locale) {
    var t = translations[locale] || translations.pt;

    // Text content
    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var key = el.getAttribute('data-i18n');
      if (t[key] !== undefined) el.textContent = t[key];
    });

    // HTML content (for elements with tags like <br/>, <span>)
    document.querySelectorAll('[data-i18n-html]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-html');
      if (t[key] !== undefined) el.innerHTML = t[key];
    });

    // aria-label attributes
    document.querySelectorAll('[data-i18n-aria]').forEach(function (el) {
      var key = el.getAttribute('data-i18n-aria');
      if (t[key] !== undefined) el.setAttribute('aria-label', t[key]);
    });

    // Sync the select value
    var sel = document.getElementById('locale-select');
    if (sel) sel.value = locale;

    // Update html lang attribute
    document.documentElement.lang = locale;
  }

  function init() {
    var locale = getLocale();
    applyTranslations(locale);

    var sel = document.getElementById('locale-select');
    if (!sel) return;

    sel.value = locale;
    sel.addEventListener('change', function () {
      var chosen = sel.value;
      if (SUPPORTED.indexOf(chosen) !== -1) {
        saveLocale(chosen);
        applyTranslations(chosen);
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
