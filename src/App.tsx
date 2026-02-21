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
      <div className="flex items-center justify-center h-screen">
        <p className="text-gray-500">A carregar...</p>
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
