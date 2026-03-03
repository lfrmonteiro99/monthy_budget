import { createContext, useContext } from "react";
import pt, { type TranslationKey } from "./locales/pt";
import en from "./locales/en";
import es from "./locales/es";
import fr from "./locales/fr";

export type Locale = "pt" | "en" | "es" | "fr";

export const LOCALE_LABELS: Record<Locale, string> = {
  pt: "Português",
  en: "English",
  es: "Español",
  fr: "Français",
};

const translations: Record<Locale, Record<TranslationKey, string>> = {
  pt,
  en,
  es,
  fr,
};

export const LOCALE_KEY = "orcamento_locale";

export function getStoredLocale(): Locale {
  try {
    const stored = localStorage.getItem(LOCALE_KEY);
    if (stored && stored in translations) return stored as Locale;
  } catch {
    // ignore
  }
  // Auto-detect from browser
  const browserLang = navigator.language.slice(0, 2).toLowerCase();
  if (browserLang in translations) return browserLang as Locale;
  return "pt";
}

export function storeLocale(locale: Locale): void {
  try {
    localStorage.setItem(LOCALE_KEY, locale);
  } catch {
    // ignore
  }
}

type TranslationParams = Record<string, string | number>;

function translate(locale: Locale, key: TranslationKey, params?: TranslationParams): string {
  let text = translations[locale]?.[key] ?? translations.pt[key] ?? key;
  if (params) {
    for (const [k, v] of Object.entries(params)) {
      text = text.replace(`{${k}}`, String(v));
    }
  }
  return text;
}

export interface I18nContextValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: TranslationKey, params?: TranslationParams) => string;
}

export const I18nContext = createContext<I18nContextValue>({
  locale: "pt",
  setLocale: () => {},
  t: (key) => translations.pt[key] ?? key,
});

export function useTranslation() {
  return useContext(I18nContext);
}

export function createTranslator(locale: Locale) {
  return (key: TranslationKey, params?: TranslationParams) => translate(locale, key, params);
}

export type { TranslationKey };
