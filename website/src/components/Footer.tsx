import { Link } from "react-router-dom";
import { useLocale } from "../context/LocaleContext";

export default function Footer() {
  const { t } = useLocale();

  return (
    <footer
      className="border-t pt-10 pb-6 transition-colors"
      style={{ background: "var(--surface)", borderTopColor: "var(--border-card)" }}
    >
      <div className="max-w-[1140px] mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-[2fr_1fr_1fr] gap-12 mb-8">
          <div>
            <Link
              to="/"
              className="flex items-center gap-3 font-bold text-xl no-underline hover:no-underline mb-2"
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
            <p className="text-sm max-w-xs" style={{ color: "var(--text-secondary)" }}>
              {t.footer_desc}
            </p>
          </div>

          <div>
            <h4
              className="text-xs font-bold uppercase tracking-wider mb-3"
              style={{ color: "var(--text-label)" }}
            >
              {t.footer_app_heading}
            </h4>
            <ul className="list-none space-y-2">
              <li>
                <a href="#funcionalidades" className="text-sm no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>
                  {t.footer_feat_link}
                </a>
              </li>
              <li>
                <a href="#ecras" className="text-sm no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>
                  {t.footer_screens_link}
                </a>
              </li>
              <li>
                <a href="#download" className="text-sm no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>
                  {t.footer_download_link}
                </a>
              </li>
            </ul>
          </div>

          <div>
            <h4
              className="text-xs font-bold uppercase tracking-wider mb-3"
              style={{ color: "var(--text-label)" }}
            >
              {t.footer_legal_heading}
            </h4>
            <ul className="list-none space-y-2">
              <li>
                <Link to="/privacy-policy" className="text-sm no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>
                  {t.footer_privacy_link}
                </Link>
              </li>
              <li>
                <Link to="/terms-of-use" className="text-sm no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>
                  {t.footer_terms_link}
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div
          className="border-t pt-5 flex flex-wrap justify-between items-center gap-3 text-xs"
          style={{ borderTopColor: "var(--border-card)", color: "var(--text-muted)" }}
        >
          <span>{t.footer_copyright}</span>
          <span>{t.footer_made_in}</span>
          <span className="opacity-70">v1.0</span>
        </div>
      </div>
    </footer>
  );
}
