import { Globe } from "lucide-react";
import { useTranslation, LOCALE_LABELS, type Locale } from "../i18n";

const LOCALES = Object.entries(LOCALE_LABELS) as [Locale, string][];

export default function LocaleSelector() {
  const { locale, setLocale, t } = useTranslation();

  return (
    <div className="relative inline-flex items-center">
      <Globe size={15} className="absolute left-2.5 text-slate-400 dark:text-slate-500 pointer-events-none" />
      <select
        value={locale}
        onChange={(e) => setLocale(e.target.value as Locale)}
        aria-label={t("language")}
        className="appearance-none bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 rounded-xl pl-8 pr-3 py-2 text-xs font-semibold text-slate-600 dark:text-slate-300 cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-600 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all shadow-sm"
      >
        {LOCALES.map(([code, label]) => (
          <option key={code} value={code}>
            {label}
          </option>
        ))}
      </select>
    </div>
  );
}
