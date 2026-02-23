import { useState, useMemo } from "react";
import {
  LayoutDashboard,
  ChefHat,
  Settings as SettingsIcon,
} from "lucide-react";
import Dashboard from "./components/Dashboard";
import Settings from "./components/Settings";
import MealPlanner from "./components/MealPlanner";
import { useAppSettings } from "./hooks/useAppSettings";
import { calculateBudgetSummary } from "./utils/calculations";

type View = "dashboard" | "meal_planner" | "settings";

const NAV_ITEMS: { view: View; label: string; icon: typeof LayoutDashboard }[] = [
  { view: "dashboard", label: "Orcamento", icon: LayoutDashboard },
  { view: "meal_planner", label: "Refeicoes", icon: ChefHat },
  { view: "settings", label: "Definicoes", icon: SettingsIcon },
];

function App() {
  const { settings, setSettings, loaded } = useAppSettings();
  const [view, setView] = useState<View>("dashboard");

  const summary = useMemo(
    () =>
      calculateBudgetSummary(settings.salaries, settings.personalInfo, settings.expenses),
    [settings],
  );

  if (!loaded) {
    return (
      <div className="flex flex-col items-center justify-center h-screen bg-slate-50 gap-4">
        <div className="w-10 h-10 border-[3px] border-slate-200 border-t-blue-500 rounded-full animate-spin-slow" />
        <p className="text-slate-400 text-sm font-medium animate-pulse-soft">A carregar...</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-screen">
      {/* Main content area */}
      <div className="flex-1 overflow-y-auto pb-[72px]">
        {view === "dashboard" && (
          <Dashboard
            settings={settings}
            summary={summary}
            onOpenSettings={() => setView("settings")}
          />
        )}
        {view === "meal_planner" && (
          <MealPlanner
            settings={settings}
            onUpdateSettings={setSettings}
          />
        )}
        {view === "settings" && (
          <Settings
            settings={settings}
            onSave={setSettings}
            onBack={() => setView("dashboard")}
          />
        )}
      </div>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-slate-100 px-2 z-50"
        style={{ paddingBottom: "env(safe-area-inset-bottom)" }}
      >
        <div className="max-w-lg mx-auto flex items-center justify-around">
          {NAV_ITEMS.map(({ view: navView, label, icon: Icon }) => {
            const isActive = view === navView;
            return (
              <button
                key={navView}
                onClick={() => setView(navView)}
                className={`flex flex-col items-center gap-1 py-3 px-4 transition-colors min-w-[64px] ${
                  isActive
                    ? "text-blue-500"
                    : "text-slate-400 hover:text-slate-500"
                }`}
              >
                <Icon
                  size={22}
                  strokeWidth={isActive ? 2.5 : 2}
                  className="transition-all"
                />
                <span
                  className={`text-[10px] font-semibold tracking-wide ${
                    isActive ? "text-blue-500" : "text-slate-400"
                  }`}
                >
                  {label}
                </span>
                {isActive && (
                  <div className="absolute top-0 w-8 h-0.5 bg-blue-500 rounded-full" />
                )}
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}

export default App;
