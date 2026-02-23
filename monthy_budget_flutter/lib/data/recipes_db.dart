import '../models/meal_plan.dart';

/// Portuguese recipe database organized by protein cluster.
/// Quantities are per person in base units.
/// Recipes designed around realistic Portuguese home cooking.

const kRecipes = <String, Recipe>{
  // ─── Cluster: FRANGO ──────────────────────────────────────────────────

  'frango_assado_batata': Recipe(
    id: 'frango_assado_batata',
    nome: 'Frango Assado com Batata',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_coxa', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 60,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: true,
  ),

  'frango_estufado_arroz': Recipe(
    id: 'frango_estufado_arroz',
    nome: 'Frango Estufado com Arroz',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_coxa', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'tomate_pelado', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 45,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: true,
  ),

  'peito_grelhado_legumes': Recipe(
    id: 'peito_grelhado_legumes',
    nome: 'Peito de Frango Grelhado com Legumes',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_peito', quantidadePorPessoa: 0.18),
      RecipeIngredient(ingredientId: 'broculos', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 25,
    complexidade: 1,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: false,
  ),

  'massa_frango_cogumelos': Recipe(
    id: 'massa_frango_cogumelos',
    nome: 'Massa de Frango com Cogumelos',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_peito', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'massa', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cogumelos', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'natas', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 30,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: false,
  ),

  'arroz_frango': Recipe(
    id: 'arroz_frango',
    nome: 'Arroz de Frango',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_coxa', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'ervilhas_cong', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 40,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: true,
  ),

  'frango_courgette': Recipe(
    id: 'frango_courgette',
    nome: 'Frango Salteado com Courgette',
    ingredientes: [
      RecipeIngredient(ingredientId: 'frango_peito', quantidadePorPessoa: 0.18),
      RecipeIngredient(ingredientId: 'courgette', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'pimento', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 25,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.frango,
    reutilizavel: false,
  ),

  // ─── Cluster: OVOS ────────────────────────────────────────────────────

  'omeleta_legumes': Recipe(
    id: 'omeleta_legumes',
    nome: 'Omeleta de Legumes',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.25), // 3 ovos
      RecipeIngredient(ingredientId: 'pimento', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'queijo_ralado', quantidadePorPessoa: 0.02),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 15,
    complexidade: 1,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: false,
  ),

  'ovos_mexidos_tomate': Recipe(
    id: 'ovos_mexidos_tomate',
    nome: 'Ovos Mexidos com Tomate',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'tomate', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'pao', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 15,
    complexidade: 1,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: false,
  ),

  'tortilha_batata': Recipe(
    id: 'tortilha_batata',
    nome: 'Tortilha de Batata',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.03),
    ],
    tempoPreparacao: 30,
    complexidade: 2,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: true,
  ),

  'arroz_tomate_ovo': Recipe(
    id: 'arroz_tomate_ovo',
    nome: 'Arroz de Tomate com Ovo Estrelado',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.17), // 2 ovos
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 25,
    complexidade: 1,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: false,
  ),

  'ovos_espinafres': Recipe(
    id: 'ovos_espinafres',
    nome: 'Ovos com Espinafres e Batata',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'espinafres', quantidadePorPessoa: 0.12),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 25,
    complexidade: 1,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: false,
  ),

  'massa_carbonara': Recipe(
    id: 'massa_carbonara',
    nome: 'Massa a Carbonara',
    ingredientes: [
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.17),
      RecipeIngredient(ingredientId: 'massa', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'fiambre', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'queijo_ralado', quantidadePorPessoa: 0.02),
      RecipeIngredient(ingredientId: 'natas', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 20,
    complexidade: 2,
    tipo: RecipeType.ovos,
    proteinCluster: ProteinCluster.ovos,
    reutilizavel: false,
  ),

  // ─── Cluster: CARNE PICADA ────────────────────────────────────────────

  'bolonhesa': Recipe(
    id: 'bolonhesa',
    nome: 'Esparguete a Bolonhesa',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada_mista', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'massa', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 35,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: true,
  ),

  'almondegas_arroz': Recipe(
    id: 'almondegas_arroz',
    nome: 'Almondegas com Arroz',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada_mista', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'pao', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 40,
    complexidade: 3,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: true,
  ),

  'empadao': Recipe(
    id: 'empadao',
    nome: 'Empadao de Carne',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'ervilhas_cong', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'leite', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 50,
    complexidade: 3,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: true,
  ),

  'carne_picada_pure': Recipe(
    id: 'carne_picada_pure',
    nome: 'Carne Picada com Pure',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada_mista', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'leite', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'manteiga', quantidadePorPessoa: 0.01),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 35,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: false,
  ),

  'arroz_carne_picada': Recipe(
    id: 'arroz_carne_picada',
    nome: 'Arroz de Carne Picada',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada_mista', quantidadePorPessoa: 0.12),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'tomate_pelado', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 30,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: true,
  ),

  'massa_carne_picada': Recipe(
    id: 'massa_carne_picada',
    nome: 'Massa com Carne Picada e Legumes',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carne_picada_mista', quantidadePorPessoa: 0.12),
      RecipeIngredient(ingredientId: 'massa', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'courgette', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 25,
    complexidade: 2,
    tipo: RecipeType.carne,
    proteinCluster: ProteinCluster.carnePicada,
    reutilizavel: false,
  ),

  // ─── Cluster: LEGUMINOSAS ─────────────────────────────────────────────

  'feijoada': Recipe(
    id: 'feijoada',
    nome: 'Feijoada a Portuguesa',
    ingredientes: [
      RecipeIngredient(ingredientId: 'feijao_seco', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'salsichas', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'couve', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 60,
    complexidade: 3,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: true,
  ),

  'sopa_lentilhas': Recipe(
    id: 'sopa_lentilhas',
    nome: 'Sopa de Lentilhas',
    ingredientes: [
      RecipeIngredient(ingredientId: 'lentilhas', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 35,
    complexidade: 1,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: true,
  ),

  'arroz_feijao': Recipe(
    id: 'arroz_feijao',
    nome: 'Arroz de Feijao',
    ingredientes: [
      RecipeIngredient(ingredientId: 'feijao_seco', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
      RecipeIngredient(ingredientId: 'louro', quantidadePorPessoa: 0.1),
    ],
    tempoPreparacao: 40,
    complexidade: 2,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: true,
  ),

  'estufado_grao': Recipe(
    id: 'estufado_grao',
    nome: 'Estufado de Grao com Espinafres',
    ingredientes: [
      RecipeIngredient(ingredientId: 'grao_bico', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'espinafres', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'tomate_pelado', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.02),
    ],
    tempoPreparacao: 35,
    complexidade: 2,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: true,
  ),

  'salada_feijao_atum': Recipe(
    id: 'salada_feijao_atum',
    nome: 'Salada de Feijao com Atum',
    ingredientes: [
      RecipeIngredient(ingredientId: 'feijao_seco', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'atum_lata', quantidadePorPessoa: 0.5),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'tomate', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
      RecipeIngredient(ingredientId: 'vinagre', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 15,
    complexidade: 1,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: false,
  ),

  'sopa_grao': Recipe(
    id: 'sopa_grao',
    nome: 'Sopa de Grao-de-Bico',
    ingredientes: [
      RecipeIngredient(ingredientId: 'grao_bico', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cenoura', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'couve', quantidadePorPessoa: 0.06),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 35,
    complexidade: 1,
    tipo: RecipeType.leguminosas,
    proteinCluster: ProteinCluster.leguminosas,
    reutilizavel: true,
  ),

  // ─── Cluster: PEIXE BARATO ────────────────────────────────────────────

  'sardinhas_batata': Recipe(
    id: 'sardinhas_batata',
    nome: 'Sardinhas Assadas com Batata',
    ingredientes: [
      RecipeIngredient(ingredientId: 'sardinha', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'pimento', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 30,
    complexidade: 2,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: false,
  ),

  'carapau_arroz_tomate': Recipe(
    id: 'carapau_arroz_tomate',
    nome: 'Carapau Frito com Arroz de Tomate',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carapau', quantidadePorPessoa: 0.20),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.08),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'oleo', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.01),
    ],
    tempoPreparacao: 35,
    complexidade: 2,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: false,
  ),

  'bacalhau_bras': Recipe(
    id: 'bacalhau_bras',
    nome: 'Bacalhau a Bras',
    ingredientes: [
      RecipeIngredient(ingredientId: 'bacalhau', quantidadePorPessoa: 0.12),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'ovos', quantidadePorPessoa: 0.17),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.02),
    ],
    tempoPreparacao: 35,
    complexidade: 3,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: false,
  ),

  'atum_massa': Recipe(
    id: 'atum_massa',
    nome: 'Massa de Atum',
    ingredientes: [
      RecipeIngredient(ingredientId: 'atum_lata', quantidadePorPessoa: 0.75),
      RecipeIngredient(ingredientId: 'massa', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'polpa_tomate', quantidadePorPessoa: 0.25),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'alho', quantidadePorPessoa: 0.005),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 20,
    complexidade: 1,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: false,
  ),

  'caldeirada_simples': Recipe(
    id: 'caldeirada_simples',
    nome: 'Caldeirada Simples',
    ingredientes: [
      RecipeIngredient(ingredientId: 'carapau', quantidadePorPessoa: 0.18),
      RecipeIngredient(ingredientId: 'batata', quantidadePorPessoa: 0.15),
      RecipeIngredient(ingredientId: 'tomate', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'pimento', quantidadePorPessoa: 0.05),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 40,
    complexidade: 2,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: true,
  ),

  'arroz_atum': Recipe(
    id: 'arroz_atum',
    nome: 'Arroz de Atum',
    ingredientes: [
      RecipeIngredient(ingredientId: 'atum_lata', quantidadePorPessoa: 0.75),
      RecipeIngredient(ingredientId: 'arroz', quantidadePorPessoa: 0.10),
      RecipeIngredient(ingredientId: 'cebola', quantidadePorPessoa: 0.03),
      RecipeIngredient(ingredientId: 'ervilhas_cong', quantidadePorPessoa: 0.04),
      RecipeIngredient(ingredientId: 'azeite', quantidadePorPessoa: 0.015),
    ],
    tempoPreparacao: 25,
    complexidade: 1,
    tipo: RecipeType.peixe,
    proteinCluster: ProteinCluster.peixeBarato,
    reutilizavel: false,
  ),
};

/// Get recipes for a specific protein cluster.
List<Recipe> getRecipesByCluster(ProteinCluster cluster) =>
    kRecipes.values.where((r) => r.proteinCluster == cluster).toList();

/// Get a recipe by id.
Recipe? getRecipe(String id) => kRecipes[id];

/// All recipes as list.
List<Recipe> get allRecipes => kRecipes.values.toList();
