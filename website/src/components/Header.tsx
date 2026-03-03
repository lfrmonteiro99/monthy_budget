import { useState, useEffect } from "react";
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

  // Close menu on route change
  useEffect(() => { setMenuOpen(false); }, [location.pathname]);

  // Prevent body scroll when menu is open
  useEffect(() => {
    if (menuOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => { document.body.style.overflow = ""; };
  }, [menuOpen]);

  const navItems = isHome
    ? [
        { label: t.nav_home, href: "#", isHash: true },
        { label: t.nav_features, href: "#funcionalidades", isHash: true },
        { label: t.nav_pricing, href: "#precos", isHash: true },
        { label: t.nav_screens, href: "#ecras", isHash: true },
        { label: t.nav_usecases, href: "#casos-de-uso", isHash: true },
        { label: t.nav_privacy, href: "/privacy-policy", isHash: false },
        { label: t.nav_terms, href: "/terms-of-use", isHash: false },
      ]
    : [
        { label: t.nav_home, href: "/", isHash: false },
        { label: t.nav_features, href: "/#funcionalidades", isHash: false },
        { label: t.nav_pricing, href: "/#precos", isHash: false },
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
    if (!item.isHash) return location.pathname === item.href;
    return false;
  };

  const NavLink = ({ item }: { item: (typeof navItems)[0] }) => {
    const active = isActive(item);
    const baseClasses = "block px-4 py-3 rounded-xl text-[0.9rem] font-medium transition-all no-underline hover:no-underline min-h-[44px] flex items-center";

    if (item.isHash) {
      return (
        <a
          href={item.href}
          onClick={(e) => { e.preventDefault(); handleNavClick(item); }}
          className={baseClasses}
          style={{ color: "var(--text-secondary)" }}
        >
          {item.label}
        </a>
      );
    }

    return (
      <Link
        to={item.href}
        onClick={() => setMenuOpen(false)}
        className={baseClasses}
        style={{
          color: active ? "var(--primary-val)" : "var(--text-secondary)",
          background: active ? "var(--primary-light-val)" : "transparent",
        }}
      >
        {item.label}
      </Link>
    );
  };

  return (
    <header
      className="sticky top-0 z-50 backdrop-blur-xl border-b transition-colors duration-300"
      style={{ background: "var(--header-bg)", borderBottomColor: "var(--header-border)" }}
    >
      <nav className="max-w-[1140px] mx-auto px-4 sm:px-6 flex items-center justify-between h-[64px] sm:h-[72px]">
        {/* Brand */}
        <Link
          to="/"
          className="flex items-center gap-2 sm:gap-3 font-bold text-lg sm:text-xl no-underline hover:no-underline shrink-0"
          style={{ color: "var(--text-primary)" }}
        >
          <div className="w-9 h-9 sm:w-10 sm:h-10 rounded-xl bg-gradient-to-br from-blue-500 to-blue-700 flex items-center justify-center text-white shrink-0">
            <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 12V7H5a2 2 0 0 1 0-4h14v4" />
              <path d="M3 5v14a2 2 0 0 0 2 2h16v-5" />
              <path d="M18 12a2 2 0 0 0 0 4h4v-4Z" />
            </svg>
          </div>
          <span className="hidden xs:inline">Gestão Mensal</span>
          <span className="xs:hidden">GM</span>
        </Link>

        {/* Desktop nav - hidden on mobile, all links go in hamburger */}
        <ul className="hidden lg:flex items-center gap-1 list-none">
          {navItems.map((item) => (
            <li key={item.href}>
              <NavLink item={item} />
            </li>
          ))}
        </ul>

        {/* Actions */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {/* Locale - hidden on mobile, shown in hamburger menu */}
          <select
            value={locale}
            onChange={(e) => setLocale(e.target.value as Locale)}
            className="hidden sm:block appearance-none rounded-xl px-3 py-2 text-xs font-semibold cursor-pointer transition-all border focus:outline-2 focus:outline-blue-500 min-h-[44px]"
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

          {/* Theme toggle - always visible, 44px touch target */}
          <button
            onClick={toggleTheme}
            className="w-11 h-11 rounded-full flex items-center justify-center cursor-pointer transition-all border shrink-0"
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

          {/* Hamburger - visible on mobile & tablet, hidden on lg */}
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            className="lg:hidden w-11 h-11 flex items-center justify-center bg-transparent border-none cursor-pointer rounded-xl shrink-0"
            style={{ color: "var(--text-primary)" }}
            aria-label="Menu"
            aria-expanded={menuOpen}
          >
            <div className="relative w-6 h-5">
              <motion.span
                className="absolute left-0 w-6 h-0.5 rounded-full"
                style={{ background: "currentColor" }}
                animate={menuOpen ? { top: "50%", rotate: 45, translateY: "-50%" } : { top: 0, rotate: 0, translateY: 0 }}
                transition={{ duration: 0.2 }}
              />
              <motion.span
                className="absolute left-0 top-1/2 -translate-y-1/2 w-6 h-0.5 rounded-full"
                style={{ background: "currentColor" }}
                animate={menuOpen ? { opacity: 0, scaleX: 0 } : { opacity: 1, scaleX: 1 }}
                transition={{ duration: 0.15 }}
              />
              <motion.span
                className="absolute left-0 w-6 h-0.5 rounded-full"
                style={{ background: "currentColor" }}
                animate={menuOpen ? { bottom: "50%", rotate: -45, translateY: "50%" } : { bottom: 0, rotate: 0, translateY: 0 }}
                transition={{ duration: 0.2 }}
              />
            </div>
          </button>
        </div>
      </nav>

      {/* Mobile/Tablet slide-down menu */}
      <AnimatePresence>
        {menuOpen && (
          <>
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="lg:hidden fixed inset-0 top-[64px] sm:top-[72px] z-40"
              style={{ background: "rgba(0,0,0,0.3)" }}
              onClick={() => setMenuOpen(false)}
            />

            {/* Menu panel */}
            <motion.div
              initial={{ opacity: 0, y: -8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -8 }}
              transition={{ duration: 0.2 }}
              className="lg:hidden absolute top-full left-0 right-0 z-50 border-b shadow-lg max-h-[calc(100vh-64px)] sm:max-h-[calc(100vh-72px)] overflow-y-auto"
              style={{
                background: "var(--surface)",
                borderBottomColor: "var(--border-card)",
                boxShadow: "var(--shadow-lg)",
              }}
            >
              <ul className="list-none p-4 space-y-1">
                {navItems.map((item) => (
                  <li key={item.href}>
                    <NavLink item={item} />
                  </li>
                ))}
              </ul>

              {/* Mobile locale selector */}
              <div className="sm:hidden px-4 pb-4 border-t pt-4" style={{ borderTopColor: "var(--border-card)" }}>
                <label className="text-xs font-semibold block mb-2" style={{ color: "var(--text-muted)" }}>
                  {t.nav_lang_aria}
                </label>
                <div className="flex gap-2">
                  {(["pt", "en", "es", "fr"] as Locale[]).map((lang) => (
                    <button
                      key={lang}
                      onClick={() => { setLocale(lang); setMenuOpen(false); }}
                      className="flex-1 py-2.5 rounded-xl text-xs font-bold uppercase transition-all border-none cursor-pointer min-h-[44px]"
                      style={{
                        background: locale === lang ? "var(--primary-val)" : "var(--surface-variant)",
                        color: locale === lang ? "var(--on-primary)" : "var(--text-secondary)",
                      }}
                    >
                      {lang.toUpperCase()}
                    </button>
                  ))}
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </header>
  );
}
