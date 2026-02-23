import type { FoodItem, MealPlanDay, MealIngredient, BudgetSummary } from "../types";

interface MealTemplate {
  nameTemplate: string;
  descriptionTemplate: string;
  slots: {
    category: string;
    baseQty: number;
    unit: string;
  }[];
}

const MEAL_TEMPLATES: MealTemplate[] = [
  {
    nameTemplate: "{proteina} grelhado(a) com {cereal} e {legume}",
    descriptionTemplate: "{proteina} grelhado(a), acompanhado(a) de {cereal} e {legume} salteado(a)",
    slots: [
      { category: "proteinas", baseQty: 200, unit: "g" },
      { category: "cereais", baseQty: 150, unit: "g" },
      { category: "legumes", baseQty: 150, unit: "g" },
    ],
  },
  {
    nameTemplate: "{proteina} estufado(a) com {legume}",
    descriptionTemplate: "{proteina} estufado(a) com {legume} e ervas aromáticas",
    slots: [
      { category: "proteinas", baseQty: 250, unit: "g" },
      { category: "legumes", baseQty: 200, unit: "g" },
      { category: "temperos", baseQty: 1, unit: "q.b." },
    ],
  },
  {
    nameTemplate: "{cereal} com {proteina} e {legume}",
    descriptionTemplate: "{cereal} salteado(a) com {proteina} e {legume}",
    slots: [
      { category: "cereais", baseQty: 200, unit: "g" },
      { category: "proteinas", baseQty: 180, unit: "g" },
      { category: "legumes", baseQty: 150, unit: "g" },
    ],
  },
  {
    nameTemplate: "Sopa de {legume} com {proteina}",
    descriptionTemplate: "Sopa cremosa de {legume}, servida com {proteina}",
    slots: [
      { category: "legumes", baseQty: 300, unit: "g" },
      { category: "proteinas", baseQty: 150, unit: "g" },
    ],
  },
  {
    nameTemplate: "{proteina} no forno com {legume} e {cereal}",
    descriptionTemplate: "{proteina} assado(a) no forno com {legume} e {cereal}",
    slots: [
      { category: "proteinas", baseQty: 250, unit: "g" },
      { category: "legumes", baseQty: 200, unit: "g" },
      { category: "cereais", baseQty: 150, unit: "g" },
    ],
  },
  {
    nameTemplate: "Salada de {legume} com {proteina}",
    descriptionTemplate: "Salada fresca de {legume} com {proteina} e temperos",
    slots: [
      { category: "legumes", baseQty: 250, unit: "g" },
      { category: "proteinas", baseQty: 180, unit: "g" },
      { category: "temperos", baseQty: 1, unit: "q.b." },
    ],
  },
  {
    nameTemplate: "{proteina} com {cereal}",
    descriptionTemplate: "{proteina} cozido(a), servido(a) com {cereal}",
    slots: [
      { category: "proteinas", baseQty: 220, unit: "g" },
      { category: "cereais", baseQty: 180, unit: "g" },
    ],
  },
  {
    nameTemplate: "Empadão de {proteina} com {legume}",
    descriptionTemplate: "Empadão de {proteina} com camada de {legume} e puré",
    slots: [
      { category: "proteinas", baseQty: 200, unit: "g" },
      { category: "legumes", baseQty: 200, unit: "g" },
      { category: "cereais", baseQty: 150, unit: "g" },
    ],
  },
  {
    nameTemplate: "{legume} recheado(a) com {proteina}",
    descriptionTemplate: "{legume} recheado(a) com {proteina} e gratinado(a)",
    slots: [
      { category: "legumes", baseQty: 250, unit: "g" },
      { category: "proteinas", baseQty: 180, unit: "g" },
      { category: "laticinios", baseQty: 50, unit: "g" },
    ],
  },
  {
    nameTemplate: "{cereal} de {proteina} com {legume}",
    descriptionTemplate: "{cereal} preparado(a) com {proteina} salteado(a) e {legume}",
    slots: [
      { category: "cereais", baseQty: 200, unit: "g" },
      { category: "proteinas", baseQty: 200, unit: "g" },
      { category: "legumes", baseQty: 150, unit: "g" },
    ],
  },
];

function seededRandom(seed: number): () => number {
  let s = seed;
  return () => {
    s = (s * 1664525 + 1013904223) & 0xffffffff;
    return (s >>> 0) / 0xffffffff;
  };
}

function shuffle<T>(arr: T[], rng: () => number): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

function getFoodsByCategory(foods: FoodItem[]): Record<string, FoodItem[]> {
  const map: Record<string, FoodItem[]> = {};
  for (const f of foods) {
    if (!map[f.category]) map[f.category] = [];
    map[f.category].push(f);
  }
  return map;
}

function portionMultiplier(dependentes: number): number {
  // Base: 2 adults. Each dependent adds ~0.5 portion (children eat less)
  const people = 2 + dependentes * 0.5;
  return people / 2;
}

function budgetFactor(summary: BudgetSummary): "economico" | "normal" | "confortavel" {
  const netPerPerson = summary.totalNetWithMeal / Math.max(1, 2);
  if (netPerPerson < 600) return "economico";
  if (netPerPerson < 1200) return "normal";
  return "confortavel";
}

export function generateMealPlan(
  foods: FoodItem[],
  daysInMonth: number,
  dependentes: number,
  summary: BudgetSummary,
): MealPlanDay[] {
  if (foods.length === 0) return [];

  const byCategory = getFoodsByCategory(foods);
  const multiplier = portionMultiplier(dependentes);
  const budget = budgetFactor(summary);

  // Budget affects portion sizes slightly
  const budgetMultiplier = budget === "economico" ? 0.85 : budget === "confortavel" ? 1.15 : 1.0;

  const seed = daysInMonth * 1000 + foods.length * 100 + dependentes;
  const rng = seededRandom(seed);

  // Shuffle templates for variety
  const shuffledTemplates = shuffle(MEAL_TEMPLATES, rng);

  // Track recently used foods to add variety
  const recentProteins: string[] = [];
  const recentCereals: string[] = [];

  const meals: MealPlanDay[] = [];

  for (let day = 1; day <= daysInMonth; day++) {
    const templateIdx = (day - 1) % shuffledTemplates.length;
    const template = shuffledTemplates[templateIdx];

    // If we cycled through all templates, reshuffle for next round
    if (day > 1 && templateIdx === 0) {
      const reshuffled = shuffle(MEAL_TEMPLATES, rng);
      for (let i = 0; i < reshuffled.length; i++) {
        shuffledTemplates[i] = reshuffled[i];
      }
    }

    const ingredients: MealIngredient[] = [];
    const replacements: Record<string, string> = {};

    for (const slot of template.slots) {
      const available = byCategory[slot.category];
      if (!available || available.length === 0) {
        // Fall back to any available food
        const allFoods = shuffle(foods, rng);
        if (allFoods.length === 0) continue;
        const pick = allFoods[0];
        const qty = slot.unit === "q.b." ? slot.baseQty : Math.round(slot.baseQty * multiplier * budgetMultiplier);
        ingredients.push({ foodName: pick.name, quantity: qty, unit: slot.unit });
        if (!replacements[slot.category]) replacements[slot.category] = pick.name;
        continue;
      }

      // Try to pick a food not recently used
      const shuffled = shuffle(available, rng);
      let picked = shuffled[0];

      if (slot.category === "proteinas") {
        const nonRecent = shuffled.filter((f) => !recentProteins.includes(f.id));
        if (nonRecent.length > 0) picked = nonRecent[0];
        recentProteins.push(picked.id);
        if (recentProteins.length > 3) recentProteins.shift();
      } else if (slot.category === "cereais") {
        const nonRecent = shuffled.filter((f) => !recentCereals.includes(f.id));
        if (nonRecent.length > 0) picked = nonRecent[0];
        recentCereals.push(picked.id);
        if (recentCereals.length > 2) recentCereals.shift();
      }

      const qty = slot.unit === "q.b." ? slot.baseQty : Math.round(slot.baseQty * multiplier * budgetMultiplier);
      ingredients.push({ foodName: picked.name, quantity: qty, unit: slot.unit });

      // Map category to replacement key
      const catKey =
        slot.category === "proteinas"
          ? "proteina"
          : slot.category === "legumes"
            ? "legume"
            : slot.category === "cereais"
              ? "cereal"
              : slot.category === "laticinios"
                ? "laticinio"
                : slot.category === "temperos"
                  ? "tempero"
                  : slot.category;

      if (!replacements[catKey]) replacements[catKey] = picked.name;
    }

    // Build name and description from template
    let name = template.nameTemplate;
    let description = template.descriptionTemplate;
    for (const [key, value] of Object.entries(replacements)) {
      name = name.replace(`{${key}}`, value);
      description = description.replace(`{${key}}`, value);
    }

    // Clean up any unreplaced placeholders
    name = name.replace(/\{[^}]+\}/g, "acompanhamento");
    description = description.replace(/\{[^}]+\}/g, "acompanhamento");

    meals.push({ day, name, description, ingredients });
  }

  return meals;
}

export function getDaysInNextMonth(): { year: number; month: number; days: number } {
  const now = new Date();
  const nextMonth = now.getMonth() + 1;
  const year = nextMonth > 11 ? now.getFullYear() + 1 : now.getFullYear();
  const month = nextMonth > 11 ? 0 : nextMonth;
  const days = new Date(year, month + 1, 0).getDate();
  return { year, month: month + 1, days };
}

export function getMonthName(month: number): string {
  const names = [
    "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
    "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro",
  ];
  return names[month - 1] || "";
}
