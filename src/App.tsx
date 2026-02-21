import { useState, useMemo } from "react";
import Dashboard from "./components/Dashboard";
import Settings from "./components/Settings";
import { useAppSettings } from "./hooks/useAppSettings";
import { calculateBudgetSummary } from "./utils/calculations";

type View = "dashboard" | "settings";

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

  if (view === "settings") {
    return (
      <Settings
        settings={settings}
        onSave={setSettings}
        onBack={() => setView("dashboard")}
      />
    );
  }

  return (
    <Dashboard
      settings={settings}
      summary={summary}
      onOpenSettings={() => setView("settings")}
    />
  );
}

export default App;
