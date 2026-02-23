import 'dart:convert';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum IngredientCategory {
  proteina,
  carboidrato,
  vegetal,
  gordura,
  lacticinio,
  tempero,
  fruta,
  outro;

  String get label {
    switch (this) {
      case IngredientCategory.proteina:
        return 'Proteinas';
      case IngredientCategory.carboidrato:
        return 'Carboidratos';
      case IngredientCategory.vegetal:
        return 'Legumes e Verduras';
      case IngredientCategory.gordura:
        return 'Gorduras e Oleos';
      case IngredientCategory.lacticinio:
        return 'Lacticinios';
      case IngredientCategory.tempero:
        return 'Temperos';
      case IngredientCategory.fruta:
        return 'Frutas';
      case IngredientCategory.outro:
        return 'Outros';
    }
  }

  static IngredientCategory fromJson(String value) {
    for (final cat in IngredientCategory.values) {
      if (cat.name == value) return cat;
    }
    return IngredientCategory.outro;
  }
}

enum RecipeType {
  carne,
  peixe,
  vegetariano,
  ovos,
  leguminosas;

  String get label {
    switch (this) {
      case RecipeType.carne:
        return 'Carne';
      case RecipeType.peixe:
        return 'Peixe';
      case RecipeType.vegetariano:
        return 'Vegetariano';
      case RecipeType.ovos:
        return 'Ovos';
      case RecipeType.leguminosas:
        return 'Leguminosas';
    }
  }

  static RecipeType fromJson(String value) {
    for (final t in RecipeType.values) {
      if (t.name == value) return t;
    }
    return RecipeType.carne;
  }
}

enum ProteinCluster {
  frango,
  ovos,
  carnePicada,
  leguminosas,
  peixeBarato;

  String get label {
    switch (this) {
      case ProteinCluster.frango:
        return 'Frango';
      case ProteinCluster.ovos:
        return 'Ovos';
      case ProteinCluster.carnePicada:
        return 'Carne Picada';
      case ProteinCluster.leguminosas:
        return 'Leguminosas';
      case ProteinCluster.peixeBarato:
        return 'Peixe';
    }
  }

  static ProteinCluster fromJson(String value) {
    for (final c in ProteinCluster.values) {
      if (c.name == value) return c;
    }
    return ProteinCluster.frango;
  }
}

enum VarietyLevel {
  economico,
  equilibrado,
  variado;

  String get label {
    switch (this) {
      case VarietyLevel.economico:
        return 'Economico';
      case VarietyLevel.equilibrado:
        return 'Equilibrado';
      case VarietyLevel.variado:
        return 'Variado';
    }
  }

  /// Number of unique recipes per week for this variety level.
  int get recipesPerWeek {
    switch (this) {
      case VarietyLevel.economico:
        return 4;
      case VarietyLevel.equilibrado:
        return 6;
      case VarietyLevel.variado:
        return 8;
    }
  }

  static VarietyLevel fromJson(String value) {
    for (final v in VarietyLevel.values) {
      if (v.name == value) return v;
    }
    return VarietyLevel.equilibrado;
  }
}

// ─── Core Entities ────────────────────────────────────────────────────────────

class Ingredient {
  final String id;
  final String nome;
  final IngredientCategory categoria;
  final String unidadeBase; // kg, unidade, litro, duzia
  final double precoMedioUnitario; // EUR per base unit
  final int? densidadeCalorica; // kcal per 100g
  final List<int> mesesSazonal; // months 1-12 where in season; empty = year-round
  final double quantidadeCompraMinima; // realistic min purchase in base unit

  const Ingredient({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.unidadeBase,
    required this.precoMedioUnitario,
    this.densidadeCalorica,
    this.mesesSazonal = const [],
    required this.quantidadeCompraMinima,
  });
}

class RecipeIngredient {
  final String ingredientId;
  final double quantidadePorPessoa; // in base unit, per person

  const RecipeIngredient({
    required this.ingredientId,
    required this.quantidadePorPessoa,
  });

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'quantidadePorPessoa': quantidadePorPessoa,
      };

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        ingredientId: json['ingredientId'] as String,
        quantidadePorPessoa: (json['quantidadePorPessoa'] as num).toDouble(),
      );
}

class Recipe {
  final String id;
  final String nome;
  final List<RecipeIngredient> ingredientes;
  final int tempoPreparacao; // minutes
  final int complexidade; // 1-5
  final RecipeType tipo;
  final ProteinCluster proteinCluster;
  final bool reutilizavel; // good for leftovers?

  const Recipe({
    required this.id,
    required this.nome,
    required this.ingredientes,
    required this.tempoPreparacao,
    required this.complexidade,
    required this.tipo,
    required this.proteinCluster,
    this.reutilizavel = false,
  });
}

// ─── Plan Entities ────────────────────────────────────────────────────────────

class PlannedIngredient {
  final String ingredientId;
  final String nome;
  final double quantidade; // total for all people
  final String unidade;
  final double precoEstimado;

  const PlannedIngredient({
    required this.ingredientId,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.precoEstimado,
  });

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'nome': nome,
        'quantidade': quantidade,
        'unidade': unidade,
        'precoEstimado': precoEstimado,
      };

  factory PlannedIngredient.fromJson(Map<String, dynamic> json) =>
      PlannedIngredient(
        ingredientId: json['ingredientId'] as String,
        nome: json['nome'] as String,
        quantidade: (json['quantidade'] as num).toDouble(),
        unidade: json['unidade'] as String,
        precoEstimado: (json['precoEstimado'] as num).toDouble(),
      );
}

class PlannedMeal {
  final String receitaId;
  final String nomeReceita;
  final List<PlannedIngredient> ingredientes;
  final double custoEstimadoPorPessoa;
  final double custoEstimadoTotal;
  final bool isSobras;
  final String? sobrasDeReceitaId;

  const PlannedMeal({
    required this.receitaId,
    required this.nomeReceita,
    required this.ingredientes,
    required this.custoEstimadoPorPessoa,
    required this.custoEstimadoTotal,
    this.isSobras = false,
    this.sobrasDeReceitaId,
  });

  PlannedMeal copyWith({
    String? receitaId,
    String? nomeReceita,
    List<PlannedIngredient>? ingredientes,
    double? custoEstimadoPorPessoa,
    double? custoEstimadoTotal,
    bool? isSobras,
    String? sobrasDeReceitaId,
  }) {
    return PlannedMeal(
      receitaId: receitaId ?? this.receitaId,
      nomeReceita: nomeReceita ?? this.nomeReceita,
      ingredientes: ingredientes ?? this.ingredientes,
      custoEstimadoPorPessoa:
          custoEstimadoPorPessoa ?? this.custoEstimadoPorPessoa,
      custoEstimadoTotal: custoEstimadoTotal ?? this.custoEstimadoTotal,
      isSobras: isSobras ?? this.isSobras,
      sobrasDeReceitaId: sobrasDeReceitaId ?? this.sobrasDeReceitaId,
    );
  }

  Map<String, dynamic> toJson() => {
        'receitaId': receitaId,
        'nomeReceita': nomeReceita,
        'ingredientes': ingredientes.map((i) => i.toJson()).toList(),
        'custoEstimadoPorPessoa': custoEstimadoPorPessoa,
        'custoEstimadoTotal': custoEstimadoTotal,
        'isSobras': isSobras,
        'sobrasDeReceitaId': sobrasDeReceitaId,
      };

  factory PlannedMeal.fromJson(Map<String, dynamic> json) => PlannedMeal(
        receitaId: json['receitaId'] as String,
        nomeReceita: json['nomeReceita'] as String,
        ingredientes: (json['ingredientes'] as List<dynamic>)
            .map((i) => PlannedIngredient.fromJson(i as Map<String, dynamic>))
            .toList(),
        custoEstimadoPorPessoa:
            (json['custoEstimadoPorPessoa'] as num).toDouble(),
        custoEstimadoTotal: (json['custoEstimadoTotal'] as num).toDouble(),
        isSobras: json['isSobras'] as bool? ?? false,
        sobrasDeReceitaId: json['sobrasDeReceitaId'] as String?,
      );
}

class DayPlan {
  final DateTime data;
  final PlannedMeal? almoco;
  final PlannedMeal? jantar;

  const DayPlan({
    required this.data,
    this.almoco,
    this.jantar,
  });

  double get custoEstimadoDiario =>
      (almoco?.custoEstimadoTotal ?? 0) + (jantar?.custoEstimadoTotal ?? 0);

  DayPlan copyWith({
    DateTime? data,
    PlannedMeal? almoco,
    PlannedMeal? jantar,
    bool clearAlmoco = false,
    bool clearJantar = false,
  }) {
    return DayPlan(
      data: data ?? this.data,
      almoco: clearAlmoco ? null : (almoco ?? this.almoco),
      jantar: clearJantar ? null : (jantar ?? this.jantar),
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toIso8601String(),
        'almoco': almoco?.toJson(),
        'jantar': jantar?.toJson(),
      };

  factory DayPlan.fromJson(Map<String, dynamic> json) => DayPlan(
        data: DateTime.parse(json['data'] as String),
        almoco: json['almoco'] != null
            ? PlannedMeal.fromJson(json['almoco'] as Map<String, dynamic>)
            : null,
        jantar: json['jantar'] != null
            ? PlannedMeal.fromJson(json['jantar'] as Map<String, dynamic>)
            : null,
      );
}

class WeekPlan {
  final int semana; // 1-4
  final List<DayPlan> dias;
  final ProteinCluster proteinaDominante;
  final double? custoRealSemanal;

  const WeekPlan({
    required this.semana,
    required this.dias,
    required this.proteinaDominante,
    this.custoRealSemanal,
  });

  double get custoEstimadoSemanal =>
      dias.fold(0.0, (sum, d) => sum + d.custoEstimadoDiario);

  WeekPlan copyWith({
    int? semana,
    List<DayPlan>? dias,
    ProteinCluster? proteinaDominante,
    double? custoRealSemanal,
    bool clearCustoReal = false,
  }) {
    return WeekPlan(
      semana: semana ?? this.semana,
      dias: dias ?? this.dias,
      proteinaDominante: proteinaDominante ?? this.proteinaDominante,
      custoRealSemanal:
          clearCustoReal ? null : (custoRealSemanal ?? this.custoRealSemanal),
    );
  }

  Map<String, dynamic> toJson() => {
        'semana': semana,
        'dias': dias.map((d) => d.toJson()).toList(),
        'proteinaDominante': proteinaDominante.name,
        'custoRealSemanal': custoRealSemanal,
      };

  factory WeekPlan.fromJson(Map<String, dynamic> json) => WeekPlan(
        semana: json['semana'] as int,
        dias: (json['dias'] as List<dynamic>)
            .map((d) => DayPlan.fromJson(d as Map<String, dynamic>))
            .toList(),
        proteinaDominante:
            ProteinCluster.fromJson(json['proteinaDominante'] as String),
        custoRealSemanal: (json['custoRealSemanal'] as num?)?.toDouble(),
      );
}

class MealPlanConfig {
  final int nPessoas;
  final double orcamentoMensal;
  final VarietyLevel nivelVariedade;
  final int preferenciaComplexidade; // 1-5

  const MealPlanConfig({
    this.nPessoas = 2,
    this.orcamentoMensal = 300,
    this.nivelVariedade = VarietyLevel.equilibrado,
    this.preferenciaComplexidade = 3,
  });

  double get orcamentoDiario => orcamentoMensal / 30;
  double get orcamentoSemanal => orcamentoMensal / 4;

  MealPlanConfig copyWith({
    int? nPessoas,
    double? orcamentoMensal,
    VarietyLevel? nivelVariedade,
    int? preferenciaComplexidade,
  }) {
    return MealPlanConfig(
      nPessoas: nPessoas ?? this.nPessoas,
      orcamentoMensal: orcamentoMensal ?? this.orcamentoMensal,
      nivelVariedade: nivelVariedade ?? this.nivelVariedade,
      preferenciaComplexidade:
          preferenciaComplexidade ?? this.preferenciaComplexidade,
    );
  }

  Map<String, dynamic> toJson() => {
        'nPessoas': nPessoas,
        'orcamentoMensal': orcamentoMensal,
        'nivelVariedade': nivelVariedade.name,
        'preferenciaComplexidade': preferenciaComplexidade,
      };

  factory MealPlanConfig.fromJson(Map<String, dynamic> json) => MealPlanConfig(
        nPessoas: json['nPessoas'] as int? ?? 2,
        orcamentoMensal: (json['orcamentoMensal'] as num?)?.toDouble() ?? 300,
        nivelVariedade: VarietyLevel.fromJson(
            json['nivelVariedade'] as String? ?? 'equilibrado'),
        preferenciaComplexidade:
            json['preferenciaComplexidade'] as int? ?? 3,
      );
}

class MealPlan {
  final String id;
  final int mes; // 1-12
  final int ano;
  final MealPlanConfig config;
  final List<WeekPlan> semanas;

  const MealPlan({
    required this.id,
    required this.mes,
    required this.ano,
    required this.config,
    required this.semanas,
  });

  double get custoEstimadoTotal =>
      semanas.fold(0.0, (sum, w) => sum + w.custoEstimadoSemanal);

  double? get custoRealTotal {
    if (semanas.every((w) => w.custoRealSemanal == null)) return null;
    return semanas.fold(
        0.0, (sum, w) => sum + (w.custoRealSemanal ?? w.custoEstimadoSemanal));
  }

  double? get desvioPercentual {
    final real = custoRealTotal;
    if (real == null || custoEstimadoTotal == 0) return null;
    return ((real - custoEstimadoTotal) / custoEstimadoTotal) * 100;
  }

  MealPlan copyWith({
    String? id,
    int? mes,
    int? ano,
    MealPlanConfig? config,
    List<WeekPlan>? semanas,
  }) {
    return MealPlan(
      id: id ?? this.id,
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      config: config ?? this.config,
      semanas: semanas ?? this.semanas,
    );
  }

  String toJsonString() {
    final map = {
      'id': id,
      'mes': mes,
      'ano': ano,
      'config': config.toJson(),
      'semanas': semanas.map((w) => w.toJson()).toList(),
    };
    return jsonEncode(map);
  }

  factory MealPlan.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return MealPlan(
      id: map['id'] as String,
      mes: map['mes'] as int,
      ano: map['ano'] as int,
      config: MealPlanConfig.fromJson(map['config'] as Map<String, dynamic>),
      semanas: (map['semanas'] as List<dynamic>)
          .map((w) => WeekPlan.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── Shopping List ────────────────────────────────────────────────────────────

class ShoppingListItem {
  final String ingredientId;
  final String nome;
  final IngredientCategory categoria;
  final double quantidadeNecessaria;
  final double quantidadeCompra; // rounded to realistic purchase
  final String unidade;
  final double precoEstimado;
  final bool checked;
  final List<String> receitasQueUsam;

  const ShoppingListItem({
    required this.ingredientId,
    required this.nome,
    required this.categoria,
    required this.quantidadeNecessaria,
    required this.quantidadeCompra,
    required this.unidade,
    required this.precoEstimado,
    this.checked = false,
    this.receitasQueUsam = const [],
  });

  ShoppingListItem copyWith({
    bool? checked,
  }) {
    return ShoppingListItem(
      ingredientId: ingredientId,
      nome: nome,
      categoria: categoria,
      quantidadeNecessaria: quantidadeNecessaria,
      quantidadeCompra: quantidadeCompra,
      unidade: unidade,
      precoEstimado: precoEstimado,
      checked: checked ?? this.checked,
      receitasQueUsam: receitasQueUsam,
    );
  }

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'nome': nome,
        'categoria': categoria.name,
        'quantidadeNecessaria': quantidadeNecessaria,
        'quantidadeCompra': quantidadeCompra,
        'unidade': unidade,
        'precoEstimado': precoEstimado,
        'checked': checked,
        'receitasQueUsam': receitasQueUsam,
      };

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        ingredientId: json['ingredientId'] as String,
        nome: json['nome'] as String,
        categoria: IngredientCategory.fromJson(json['categoria'] as String),
        quantidadeNecessaria:
            (json['quantidadeNecessaria'] as num).toDouble(),
        quantidadeCompra: (json['quantidadeCompra'] as num).toDouble(),
        unidade: json['unidade'] as String,
        precoEstimado: (json['precoEstimado'] as num).toDouble(),
        checked: json['checked'] as bool? ?? false,
        receitasQueUsam: (json['receitasQueUsam'] as List<dynamic>?)
                ?.cast<String>() ??
            const [],
      );
}

class ShoppingList {
  final int semana; // which week this list is for
  final List<ShoppingListItem> items;

  const ShoppingList({
    required this.semana,
    this.items = const [],
  });

  double get custoEstimadoTotal =>
      items.fold(0.0, (sum, i) => sum + i.precoEstimado);

  int get totalItems => items.length;
  int get checkedItems => items.where((i) => i.checked).length;

  Map<String, List<ShoppingListItem>> get byCategory {
    final map = <String, List<ShoppingListItem>>{};
    for (final item in items) {
      final key = item.categoria.label;
      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }
    return map;
  }

  ShoppingList copyWith({
    int? semana,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      semana: semana ?? this.semana,
      items: items ?? this.items,
    );
  }

  String toJsonString() {
    final map = {
      'semana': semana,
      'items': items.map((i) => i.toJson()).toList(),
    };
    return jsonEncode(map);
  }

  factory ShoppingList.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ShoppingList(
      semana: map['semana'] as int,
      items: (map['items'] as List<dynamic>)
          .map((i) => ShoppingListItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
