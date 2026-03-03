import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

const stepIcons = [
  <svg key="h1" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>,
  <svg key="h2" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>,
  <svg key="h3" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>,
];

export default function HowItWorks() {
  const { t } = useLocale();

  const steps = [
    { title: t.how_step1_title, desc: t.how_step1_desc },
    { title: t.how_step2_title, desc: t.how_step2_desc },
    { title: t.how_step3_title, desc: t.how_step3_desc },
  ];

  return (
    <section className="py-12 sm:py-20" style={{ background: "var(--surface-variant)" }}>
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>{t.how_title}</h2>
            <p className="text-sm sm:text-base max-w-xl mx-auto" style={{ color: "var(--text-secondary)" }}>{t.how_desc}</p>
          </div>
        </AnimatedSection>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8 max-w-[900px] mx-auto">
          {steps.map((step, i) => (
            <AnimatedSection key={i} delay={i * 0.12}>
              <div className="text-center relative">
                {/* Step number */}
                <div
                  className="w-14 h-14 sm:w-16 sm:h-16 rounded-2xl flex items-center justify-center mx-auto mb-4"
                  style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}
                >
                  {stepIcons[i]}
                </div>

                {/* Connector line (desktop only) */}
                {i < 2 && (
                  <div
                    className="hidden md:block absolute top-7 sm:top-8 left-[calc(50%+40px)] w-[calc(100%-80px)] h-0.5"
                    style={{ background: "var(--border)" }}
                  />
                )}

                <div
                  className="text-xs font-bold uppercase tracking-widest mb-2"
                  style={{ color: "var(--primary-val)" }}
                >
                  {i + 1}
                </div>
                <h3 className="text-base sm:text-lg font-bold mb-2" style={{ color: "var(--text-primary)" }}>
                  {step.title}
                </h3>
                <p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
                  {step.desc}
                </p>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  );
}
