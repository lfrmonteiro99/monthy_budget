import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

const featureIcons = [
  <svg key="f1" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>,
  <svg key="f2" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><line x1="10" y1="9" x2="8" y2="9"/></svg>,
  <svg key="f3" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>,
  <svg key="f4" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>,
  <svg key="f5" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>,
  <svg key="f6" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><path d="m16 10-5.12 5.12a2 2 0 0 1-2.83 0L6 13.06"/></svg>,
];

export default function Features() {
  const { t } = useLocale();

  const features = [
    { title: t.feat1_title, desc: t.feat1_desc },
    { title: t.feat2_title, desc: t.feat2_desc },
    { title: t.feat3_title, desc: t.feat3_desc },
    { title: t.feat4_title, desc: t.feat4_desc },
    { title: t.feat5_title, desc: t.feat5_desc },
    { title: t.feat6_title, desc: t.feat6_desc },
  ];

  return (
    <section className="py-12 sm:py-20" id="funcionalidades">
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>{t.features_title}</h2>
            <p className="text-sm sm:text-base max-w-xl mx-auto" style={{ color: "var(--text-secondary)" }}>{t.features_desc}</p>
          </div>
        </AnimatedSection>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          {features.map((feat, i) => (
            <AnimatedSection key={i} delay={i * 0.08}>
              <div
                className="rounded-2xl p-5 sm:p-7 border transition-all sm:hover:-translate-y-0.5 sm:hover:border-[var(--primary-val)] h-full active:scale-[0.98]"
                style={{
                  background: "var(--surface)",
                  borderColor: "var(--border-card)",
                }}
              >
                <div
                  className="w-11 h-11 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center mb-3 sm:mb-4"
                  style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}
                >
                  {featureIcons[i]}
                </div>
                <h3 className="text-base sm:text-lg font-bold mb-2" style={{ color: "var(--text-primary)" }}>{feat.title}</h3>
                <p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>{feat.desc}</p>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  );
}
