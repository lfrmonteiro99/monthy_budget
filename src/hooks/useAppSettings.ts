import { useState, useEffect, useCallback, useRef } from "react";
import type { AppSettings } from "../types";

const STORAGE_KEY = "orcamento_settings";

const DEFAULT_SETTINGS: AppSettings = {
  personalInfo: {
    maritalStatus: "solteiro",
    dependentes: 0,
    deficiente: false,
  },
  salaries: [
    { label: "Vencimento 1", grossAmount: 0, enabled: true, titulares: 1, mealAllowanceType: "none", mealAllowancePerDay: 0, workingDaysPerMonth: 22 },
    { label: "Vencimento 2", grossAmount: 0, enabled: false, titulares: 1, mealAllowanceType: "none", mealAllowancePerDay: 0, workingDaysPerMonth: 22 },
  ],
  expenses: [
    { id: "vodafone", label: "Vodafone", amount: 0, category: "telecomunicacoes", enabled: true },
    { id: "eletricidade", label: "Eletricidade", amount: 0, category: "energia", enabled: true },
    { id: "agua", label: "Água", amount: 0, category: "agua", enabled: true },
    { id: "compras", label: "Compras / Alimentação", amount: 0, category: "alimentacao", enabled: true },
    { id: "escola", label: "Escola", amount: 0, category: "educacao", enabled: true },
  ],
  dashboardConfig: {
    showSummaryCards: true,
    enabledCharts: [
      "expenses_pie",
      "income_vs_expenses",
      "deductions_breakdown",
      "savings_rate",
    ],
  },
  mealPlannerPreferences: {
    numberOfPeopleOverride: null,
    varietyLevel: "media",
    excludedProteins: [],
    weeksToGenerate: 4,
    mealsPerDay: ["almoco", "jantar"],
  },
};

/** Detect if running inside Tauri */
function isTauri(): boolean {
  return !!(window as unknown as Record<string, unknown>).__TAURI_INTERNALS__;
}

/** Apply migrations to parsed settings (handles old formats) */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function migrateSettings(parsed: any): AppSettings {
  // Migrate: move titulares from personalInfo to each salary if needed
  if (parsed.personalInfo?.titulares !== undefined) {
    const oldTitulares = parsed.personalInfo.titulares;
    delete parsed.personalInfo.titulares;
    for (const s of parsed.salaries ?? []) {
      if (s.titulares === undefined) s.titulares = oldTitulares;
    }
  } else {
    for (const s of parsed.salaries ?? []) {
      if (s.titulares === undefined) s.titulares = 1;
    }
  }
  // Migrate: add meal allowance defaults if missing
  for (const s of parsed.salaries ?? []) {
    if (s.mealAllowanceType === undefined) s.mealAllowanceType = "none";
    if (s.mealAllowancePerDay === undefined) s.mealAllowancePerDay = 0;
    if (s.workingDaysPerMonth === undefined) s.workingDaysPerMonth = 22;
  }
  // Migrate: add meal planner preferences if missing
  if (!parsed.mealPlannerPreferences) {
    parsed.mealPlannerPreferences = DEFAULT_SETTINGS.mealPlannerPreferences;
  }
  return parsed as AppSettings;
}

/** Load from localStorage */
function loadFromStorage(): AppSettings | null {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    return migrateSettings(JSON.parse(raw));
  } catch {
    return null;
  }
}

/** Save to localStorage */
function saveToStorage(settings: AppSettings): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
  } catch {
    // storage full or unavailable
  }
}

/** Load from Tauri file backend */
async function loadFromTauri(): Promise<AppSettings | null> {
  try {
    const { invoke } = await import("@tauri-apps/api/core");
    const data = await invoke<string | null>("get_settings");
    if (!data) return null;
    return migrateSettings(JSON.parse(data));
  } catch {
    return null;
  }
}

/** Save to Tauri file backend */
async function saveToTauri(settings: AppSettings): Promise<void> {
  try {
    const { invoke } = await import("@tauri-apps/api/core");
    await invoke("save_settings", { data: JSON.stringify(settings, null, 2) });
  } catch {
    // silently ignore
  }
}

export function useAppSettings() {
  const [settings, setSettingsState] = useState<AppSettings>(DEFAULT_SETTINGS);
  const [loaded, setLoaded] = useState(false);
  const saving = useRef(false);

  // Load settings on mount
  useEffect(() => {
    const load = async () => {
      let data: AppSettings | null = null;

      if (isTauri()) {
        data = await loadFromTauri();
      } else {
        data = loadFromStorage();
      }

      if (data) setSettingsState(data);
      setLoaded(true);
    };
    load();
  }, []);

  // Persist settings whenever they change (after initial load)
  useEffect(() => {
    if (!loaded) return;
    if (saving.current) return;
    saving.current = true;

    const save = async () => {
      if (isTauri()) {
        await saveToTauri(settings);
      } else {
        saveToStorage(settings);
      }
      saving.current = false;
    };
    save();
  }, [settings, loaded]);

  const setSettings = useCallback((value: AppSettings | ((prev: AppSettings) => AppSettings)) => {
    setSettingsState(value);
  }, []);

  return { settings, setSettings, loaded, DEFAULT_SETTINGS };
}
