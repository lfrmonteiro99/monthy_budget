import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

export default function CTA() {
  const { t } = useLocale();

  return (
    <section className="py-12 sm:py-20 text-center" id="download">
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div
            className="rounded-2xl sm:rounded-3xl py-10 sm:py-16 px-6 sm:px-10 text-white"
            style={{ background: "linear-gradient(135deg, var(--cta-from), var(--cta-to))" }}
          >
            <h2 className="text-2xl sm:text-3xl font-bold mb-3 sm:mb-4">{t.cta_title}</h2>
            <p className="text-sm sm:text-base opacity-90 max-w-lg mx-auto mb-6 sm:mb-8">{t.cta_desc}</p>
            <a
              href="https://play.google.com/store/apps/details?id=com.orcamentomensal.orcamento_mensal"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-5 sm:px-7 py-3 sm:py-3.5 rounded-xl font-semibold text-sm no-underline hover:no-underline transition-all hover:-translate-y-0.5 min-h-[48px]"
              style={{
                background: "white",
                color: "#2563EB",
                boxShadow: "0 4px 14px rgba(0,0,0,0.15)"
              }}
            >
              <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M5 12h14M12 5l7 7-7 7" />
              </svg>
              {t.cta_button}
            </a>
            <p className="text-xs sm:text-sm opacity-70 mt-4">{t.cta_micro}</p>
          </div>
        </AnimatedSection>
      </div>
    </section>
  );
}
