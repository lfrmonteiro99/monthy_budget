import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { translations, type Locale, type TranslationKeys } from "../i18n/translations";

const LOCALE_KEY = "gestao_mensal_locale";
const SUPPORTED: Locale[] = ["pt", "en", "es", "fr"];

interface LocaleContextType {
  locale: Locale;
  setLocale: (l: Locale) => void;
  t: TranslationKeys;
}

const LocaleContext = createContext<LocaleContextType>({
  locale: "pt",
  setLocale: () => {},
  t: translations.pt,
});

export function useLocale() {
  return useContext(LocaleContext);
}

function getInitialLocale(): Locale {
  try {
    const saved = localStorage.getItem(LOCALE_KEY) as Locale;
    if (SUPPORTED.includes(saved)) return saved;
  } catch {}
  const lang = (navigator.language || "pt").slice(0, 2).toLowerCase() as Locale;
  return SUPPORTED.includes(lang) ? lang : "pt";
}

export function LocaleProvider({ children }: { children: ReactNode }) {
  const [locale, setLocaleState] = useState<Locale>(getInitialLocale);

  const setLocale = (l: Locale) => {
    if (SUPPORTED.includes(l)) {
      setLocaleState(l);
      try { localStorage.setItem(LOCALE_KEY, l); } catch {}
    }
  };

  useEffect(() => {
    document.documentElement.lang = locale;
  }, [locale]);

  const t = translations[locale] || translations.pt;

  return (
    <LocaleContext.Provider value={{ locale, setLocale, t }}>
      {children}
    </LocaleContext.Provider>
  );
}
