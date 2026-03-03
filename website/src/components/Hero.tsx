import { motion } from "framer-motion";
import { useLocale } from "../context/LocaleContext";
import PhoneMockup from "./PhoneMockup";

export default function Hero() {
  const { t } = useLocale();

  const stats = [
    { value: t.stat1_value, label: t.stat1_label },
    { value: t.stat2_value, label: t.stat2_label },
    { value: t.stat3_value, label: t.stat3_label },
    { value: t.stat4_value, label: t.stat4_label },
  ];

  return (
    <>
      <section className="pt-12 sm:pt-20 pb-10 sm:pb-16 text-center relative overflow-hidden" id="main-content" tabIndex={-1}>
        <div className="absolute inset-0 pointer-events-none" style={{
          background: "radial-gradient(ellipse at 50% 0%, rgba(59,130,246,0.08) 0%, transparent 70%)"
        }} />
        <div className="max-w-[1140px] mx-auto px-4 sm:px-6 relative">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-xs sm:text-sm font-semibold mb-4 sm:mb-6"
            style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}
          >
            <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M12 2L2 7l10 5 10-5-10-5Z" />
              <path d="m2 17 10 5 10-5" />
              <path d="m2 12 10 5 10-5" />
            </svg>
            {t.hero_badge}
          </motion.div>

          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="text-[1.75rem] sm:text-4xl md:text-5xl lg:text-6xl font-bold leading-tight mb-4 sm:mb-5"
            style={{ color: "var(--text-primary)" }}
          >
            {t.hero_title_line1}
            <br />
            <span className="bg-gradient-to-r from-blue-500 to-blue-700 bg-clip-text text-transparent">
              {t.hero_title_line2}
            </span>
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="text-base sm:text-lg max-w-xl mx-auto mb-6 sm:mb-9 leading-relaxed"
            style={{ color: "var(--text-secondary)" }}
          >
            {t.hero_subtitle}
          </motion.p>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="flex gap-3 sm:gap-4 justify-center flex-wrap"
          >
            <a
              href="#download"
              className="inline-flex items-center gap-2 px-5 sm:px-7 py-3 sm:py-3.5 rounded-xl font-semibold text-sm text-white no-underline hover:no-underline transition-all hover:-translate-y-0.5 min-h-[48px]"
              style={{
                background: "linear-gradient(135deg, #3B82F6, #2563EB)",
                boxShadow: "0 4px 14px rgba(59,130,246,0.35)"
              }}
            >
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor" className="shrink-0">
                <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-1.832l2.545 1.463c.486.279.756.658.756 1.066 0 .408-.27.787-.756 1.066l-2.545 1.463-2.564-2.529 2.564-2.529zM5.864 2.658L16.8 8.99l-2.302 2.302-8.635-8.635z" />
              </svg>
              <span className="hidden sm:inline">{t.hero_cta_primary}</span>
              <span className="sm:hidden">Google Play</span>
            </a>
            <a
              href="#funcionalidades"
              className="inline-flex items-center gap-2 px-5 sm:px-7 py-3 sm:py-3.5 rounded-xl font-semibold text-sm no-underline hover:no-underline transition-all hover:-translate-y-0.5 border min-h-[48px]"
              style={{
                background: "var(--surface)",
                color: "var(--text-primary)",
                borderColor: "var(--border)"
              }}
            >
              {t.hero_cta_secondary}
            </a>
          </motion.div>

          {/* Stats */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            className="mt-8 sm:mt-12"
          >
            {/* Desktop: inline with dividers */}
            <div className="hidden sm:flex items-center justify-center flex-wrap">
              {stats.map((stat, i) => (
                <div key={stat.label} className="flex items-center">
                  {i > 0 && <div className="w-px h-8" style={{ background: "var(--border)" }} />}
                  <div className="flex flex-col items-center px-5 md:px-8">
                    <span className="text-xl md:text-2xl font-bold" style={{ color: "var(--primary-val)" }}>{stat.value}</span>
                    <span className="text-xs font-medium mt-1" style={{ color: "var(--text-muted)" }}>{stat.label}</span>
                  </div>
                </div>
              ))}
            </div>

            {/* Mobile: 2x2 grid */}
            <div className="sm:hidden grid grid-cols-2 gap-3 max-w-xs mx-auto">
              {stats.map((stat) => (
                <div
                  key={stat.label}
                  className="flex flex-col items-center py-3 rounded-xl"
                  style={{ background: "var(--surface-variant)" }}
                >
                  <span className="text-xl font-bold" style={{ color: "var(--primary-val)" }}>{stat.value}</span>
                  <span className="text-[0.7rem] font-medium mt-0.5" style={{ color: "var(--text-muted)" }}>{stat.label}</span>
                </div>
              ))}
            </div>
          </motion.div>
        </div>
      </section>

      <PhoneMockup />
    </>
  );
}
