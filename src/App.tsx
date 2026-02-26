import { useState, useMemo, useEffect, useCallback } from "react";
import Dashboard from "./components/Dashboard";
import Settings from "./components/Settings";
import { useAppSettings } from "./hooks/useAppSettings";
import { calculateBudgetSummary } from "./utils/calculations";
import Toast from "./components/Toast";

type View = "dashboard" | "settings";

const THEME_KEY = "orcamento_theme";

function App() {
  const { settings, setSettings, loaded } = useAppSettings();
  const [view, setView] = useState<View>("dashboard");
  const [viewKey, setViewKey] = useState(0);
  const [toast, setToast] = useState<string | null>(null);

  // Dark mode
  const [dark, setDark] = useState(() => {
    try {
      return localStorage.getItem(THEME_KEY) === "dark";
    } catch {
      return false;
    }
  });

  useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
    try {
      localStorage.setItem(THEME_KEY, dark ? "dark" : "light");
    } catch {
      // ignore
    }
  }, [dark]);

  const toggleDark = useCallback(() => setDark((d) => !d), []);

  const summary = useMemo(
    () =>
      calculateBudgetSummary(settings.salaries, settings.personalInfo, settings.expenses),
    [settings],
  );

  const switchView = useCallback((v: View) => {
    setViewKey((k) => k + 1);
    setView(v);
  }, []);

  const handleSave = useCallback(
    (newSettings: typeof settings) => {
      setSettings(newSettings);
      setToast("Definições guardadas com sucesso");
    },
    [setSettings],
  );

  if (!loaded) {
    return <SkeletonScreen dark={dark} />;
  }

  return (
    <div className={dark ? "dark" : ""}>
      <Toast message={toast} onDone={() => setToast(null)} />
      <div key={viewKey} className="view-transition-enter">
        {view === "settings" ? (
          <Settings
            settings={settings}
            onSave={handleSave}
            onBack={() => switchView("dashboard")}
            dark={dark}
            onToggleDark={toggleDark}
          />
        ) : (
          <Dashboard
            settings={settings}
            summary={summary}
            onOpenSettings={() => switchView("settings")}
            dark={dark}
            onToggleDark={toggleDark}
          />
        )}
      </div>
    </div>
  );
}

function SkeletonScreen({ dark }: { dark: boolean }) {
  return (
    <div className={dark ? "dark" : ""}>
      <div className="min-h-screen bg-slate-50 dark:bg-slate-900 animate-fade-in">
        {/* Header skeleton */}
        <div className="bg-white dark:bg-slate-800 border-b border-slate-100 dark:border-slate-700 px-5 pt-5 pb-6">
          <div className="flex items-center justify-between mb-5">
            <div>
              <div className="skeleton h-5 w-36 mb-2" />
              <div className="skeleton h-3 w-24" />
            </div>
            <div className="skeleton h-10 w-10 rounded-xl" />
          </div>
          <div className="skeleton h-28 w-full rounded-2xl" />
        </div>
        {/* Cards skeleton */}
        <div className="max-w-lg mx-auto px-4 py-5 space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <div className="skeleton h-28 rounded-2xl" />
            <div className="skeleton h-28 rounded-2xl" />
            <div className="skeleton h-28 rounded-2xl" />
            <div className="skeleton h-28 rounded-2xl" />
          </div>
          <div className="skeleton h-44 rounded-2xl" />
          <div className="skeleton h-36 rounded-2xl" />
        </div>
      </div>
    </div>
  );
}

export default App;
