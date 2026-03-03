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
              href="#"
              className="inline-flex items-center gap-2 px-5 sm:px-7 py-3 sm:py-3.5 rounded-xl font-semibold text-sm no-underline hover:no-underline transition-all hover:-translate-y-0.5 min-h-[48px]"
              style={{
                background: "white",
                color: "#2563EB",
                boxShadow: "0 4px 14px rgba(0,0,0,0.15)"
              }}
            >
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-1.832l2.545 1.463c.486.279.756.658.756 1.066 0 .408-.27.787-.756 1.066l-2.545 1.463-2.564-2.529 2.564-2.529zM5.864 2.658L16.8 8.99l-2.302 2.302-8.635-8.635z" />
              </svg>
              {t.cta_button}
            </a>
          </div>
        </AnimatedSection>
      </div>
    </section>
  );
}
