import { useState, useMemo } from "react";
import Dashboard from "./components/Dashboard";
import Settings from "./components/Settings";
import { useAppSettings } from "./hooks/useAppSettings";
import { calculateBudgetSummary } from "./utils/calculations";

type View = "dashboard" | "settings";

function App() {
  const { settings, setSettings } = useAppSettings();
  const [view, setView] = useState<View>("dashboard");

  const summary = useMemo(
    () =>
      calculateBudgetSummary(settings.salaries, settings.personalInfo, settings.expenses),
    [settings],
  );

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
