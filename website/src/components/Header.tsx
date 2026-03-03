import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { motion, AnimatePresence } from "framer-motion";
import { useTheme } from "../context/ThemeContext";
import { useLocale } from "../context/LocaleContext";
import type { Locale } from "../i18n/translations";

export default function Header() {
  const { theme, toggleTheme } = useTheme();
  const { locale, setLocale, t } = useLocale();
  const [menuOpen, setMenuOpen] = useState(false);
  const location = useLocation();
  const isHome = location.pathname === "/";

  const navItems = isHome
    ? [
        { label: t.nav_home, href: "#", isHash: true },
        { label: t.nav_features, href: "#funcionalidades", isHash: true },
        { label: t.nav_screens, href: "#ecras", isHash: true },
        { label: t.nav_usecases, href: "#casos-de-uso", isHash: true },
        { label: t.nav_privacy, href: "/privacy-policy", isHash: false },
        { label: t.nav_terms, href: "/terms-of-use", isHash: false },
      ]
    : [
        { label: t.nav_home, href: "/", isHash: false },
        { label: t.nav_features, href: "/#funcionalidades", isHash: false },
        { label: t.nav_privacy, href: "/privacy-policy", isHash: false },
        { label: t.nav_terms, href: "/terms-of-use", isHash: false },
      ];

  const handleNavClick = (item: (typeof navItems)[0]) => {
    setMenuOpen(false);
    if (item.isHash && item.href.startsWith("#")) {
      const el = document.querySelector(item.href === "#" ? "#main-content" : item.href);
      el?.scrollIntoView({ behavior: "smooth" });
    }
  };

  const isActive = (item: (typeof navItems)[0]) => {
    if (!item.isHash) {
      return location.pathname === item.href;
    }
    return false;
  };

  return (
    <header
      className="sticky top-0 z-50 backdrop-blur-xl border-b transition-colors duration-300"
      style={{
        background: "var(--header-bg)",
        borderBottomColor: "var(--header-border)",
      }}
    >
      <nav className="max-w-[1140px] mx-auto px-6 flex items-center justify-between h-[72px]">
        {/* Brand */}
        <Link
          to="/"
          className="flex items-center gap-3 font-bold text-xl no-underline hover:no-underline"
          style={{ color: "var(--text-primary)" }}
        >
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center text-white">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
              <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
              <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
            </svg>
          </div>
          Gestão Mensal
        </Link>

        {/* Desktop nav */}
        <ul className="hidden md:flex items-center gap-2 list-none">
          {navItems.map((item) =>
            item.isHash ? (
              <li key={item.href}>
                <a
                  href={item.href}
                  onClick={(e) => {
                    e.preventDefault();
                    handleNavClick(item);
                  }}
                  className="px-4 py-2 rounded-xl text-sm font-medium transition-all no-underline hover:no-underline"
                  style={{
                    color: "var(--text-secondary)",
                    background: "transparent",
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.color = "var(--text-primary)";
                    e.currentTarget.style.background = "var(--surface-variant)";
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.color = "var(--text-secondary)";
                    e.currentTarget.style.background = "transparent";
                  }}
                >
                  {item.label}
                </a>
              </li>
            ) : (
              <li key={item.href}>
                <Link
                  to={item.href}
                  className="px-4 py-2 rounded-xl text-sm font-medium transition-all no-underline hover:no-underline"
                  style={{
                    color: isActive(item) ? "var(--primary-val)" : "var(--text-secondary)",
                    background: isActive(item) ? "var(--primary-light-val)" : "transparent",
                  }}
                  onMouseEnter={(e) => {
                    if (!isActive(item)) {
                      e.currentTarget.style.color = "var(--text-primary)";
                      e.currentTarget.style.background = "var(--surface-variant)";
                    }
                  }}
                  onMouseLeave={(e) => {
                    if (!isActive(item)) {
                      e.currentTarget.style.color = "var(--text-secondary)";
                      e.currentTarget.style.background = "transparent";
                    }
                  }}
                >
                  {item.label}
                </Link>
              </li>
            )
          )}
        </ul>

        {/* Actions */}
        <div className="flex items-center gap-2">
          <select
            value={locale}
            onChange={(e) => setLocale(e.target.value as Locale)}
            className="appearance-none rounded-xl px-2.5 py-1.5 text-xs font-semibold cursor-pointer transition-all border focus:outline-2 focus:outline-blue-500"
            style={{
              background: "var(--surface-variant)",
              borderColor: "var(--border)",
              color: "var(--text-secondary)",
            }}
            aria-label={t.nav_lang_aria}
          >
            <option value="pt">PT</option>
            <option value="en">EN</option>
            <option value="es">ES</option>
            <option value="fr">FR</option>
          </select>

          <button
            onClick={toggleTheme}
            className="w-10 h-10 rounded-full flex items-center justify-center cursor-pointer transition-all border"
            style={{
              background: "var(--surface-variant)",
              borderColor: "var(--border)",
              color: "var(--text-secondary)",
            }}
            aria-label={t.nav_theme_aria}
          >
            {theme === "dark" ? (
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
              </svg>
            ) : (
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
                <circle cx="12" cy="12" r="5" />
                <line x1="12" y1="1" x2="12" y2="3" />
                <line x1="12" y1="21" x2="12" y2="23" />
                <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" />
                <line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
                <line x1="1" y1="12" x2="3" y2="12" />
                <line x1="21" y1="12" x2="23" y2="12" />
                <line x1="4.22" y1="19.78" x2="5.64" y2="18.36" />
                <line x1="18.36" y1="5.64" x2="19.78" y2="4.22" />
              </svg>
            )}
          </button>

          {/* Mobile toggle */}
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="md:hidden p-2 bg-transparent border-none cursor-pointer"
            style={{ color: "var(--text-primary)" }}
            aria-label="Menu"
            aria-expanded={menuOpen}
          >
            <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2">
              <line x1="3" y1="6" x2="21" y2="6" />
              <line x1="3" y1="12" x2="21" y2="12" />
              <line x1="3" y1="18" x2="21" y2="18" />
            </svg>
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      <AnimatePresence>
        {menuOpen && (
          <motion.ul
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden list-none flex flex-col gap-1 px-6 pb-4 overflow-hidden"
            style={{ background: "var(--surface)" }}
          >
            {navItems.map((item) =>
              item.isHash ? (
                <li key={item.href}>
                  <a
                    href={item.href}
                    onClick={(e) => {
                      e.preventDefault();
                      handleNavClick(item);
                    }}
                    className="block px-4 py-2 rounded-xl text-sm font-medium no-underline"
                    style={{ color: "var(--text-secondary)" }}
                  >
                    {item.label}
                  </a>
                </li>
              ) : (
                <li key={item.href}>
                  <Link
                    to={item.href}
                    onClick={() => setMenuOpen(false)}
                    className="block px-4 py-2 rounded-xl text-sm font-medium no-underline"
                    style={{
                      color: isActive(item) ? "var(--primary-val)" : "var(--text-secondary)",
                      background: isActive(item) ? "var(--primary-light-val)" : "transparent",
                    }}
                  >
                    {item.label}
                  </Link>
                </li>
              )
            )}
          </motion.ul>
        )}
      </AnimatePresence>
    </header>
  );
}
