import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

const dayIcons = [
  <svg key="d1" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>,
  <svg key="d5" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>,
  <svg key="d9" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2v0a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"/></svg>,
  <svg key="d14" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>,
  <svg key="d18" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>,
  <svg key="d25" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="9" y1="21" x2="9" y2="9"/></svg>,
  <svg key="d30" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="8" r="7"/><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"/></svg>,
];

export default function Timeline() {
  const { t } = useLocale();

  const days = [
    { day: 1, title: t.timeline_day1_title, pain: t.timeline_day1_pain, resolution: t.timeline_day1_resolution },
    { day: 5, title: t.timeline_day5_title, pain: t.timeline_day5_pain, resolution: t.timeline_day5_resolution },
    { day: 9, title: t.timeline_day9_title, pain: t.timeline_day9_pain, resolution: t.timeline_day9_resolution },
    { day: 14, title: t.timeline_day14_title, pain: t.timeline_day14_pain, resolution: t.timeline_day14_resolution },
    { day: 18, title: t.timeline_day18_title, pain: t.timeline_day18_pain, resolution: t.timeline_day18_resolution },
    { day: 25, title: t.timeline_day25_title, pain: t.timeline_day25_pain, resolution: t.timeline_day25_resolution },
    { day: 30, title: t.timeline_day30_title, pain: t.timeline_day30_pain, resolution: t.timeline_day30_resolution },
  ];

  return (
    <section className="py-12 sm:py-20" id="casos-de-uso">
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>{t.timeline_title}</h2>
            <p className="text-sm sm:text-base max-w-xl mx-auto mb-4" style={{ color: "var(--text-secondary)" }}>{t.timeline_subtitle}</p>
            <p
              className="text-sm sm:text-base max-w-2xl mx-auto italic leading-relaxed rounded-2xl p-4 sm:p-5"
              style={{ background: "var(--surface-variant)", color: "var(--text-secondary)" }}
            >
              {t.timeline_intro}
            </p>
          </div>
        </AnimatedSection>

        <div className="max-w-[900px] mx-auto">
          {days.map((item, i) => (
            <AnimatedSection key={item.day} delay={i * 0.05}>
              <div className="flex gap-3 sm:gap-6 mb-8 sm:mb-10 last:mb-0">
                {/* Day badge */}
                <div className="flex flex-col items-center shrink-0">
                  <div
                    className="w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center text-xs font-bold z-[2]"
                    style={{
                      background: "var(--primary-val)",
                      color: "var(--on-primary)",
                      boxShadow: `0 0 0 4px var(--bg)`,
                    }}
                  >
                    {item.day}
                  </div>
                  {i < days.length - 1 && (
                    <div className="w-0.5 flex-1 mt-2" style={{ background: "var(--border)" }} />
                  )}
                </div>

                {/* Card */}
                <div
                  className="rounded-2xl p-4 sm:p-6 flex-1 border transition-all sm:hover:border-[var(--primary-val)] sm:hover:-translate-y-0.5"
                  style={{
                    background: "var(--surface)",
                    borderColor: "var(--border-card)",
                  }}
                >
                  <div
                    className="w-11 h-11 rounded-xl flex items-center justify-center mb-3"
                    style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}
                  >
                    {dayIcons[i]}
                  </div>
                  <h3 className="text-base font-bold italic mb-3" style={{ color: "var(--text-primary)" }}>
                    {item.title}
                  </h3>
                  <p className="text-sm leading-relaxed mb-3" style={{ color: "var(--text-muted)" }}>
                    {item.pain}
                  </p>
                  <p
                    className="text-sm leading-relaxed pl-3.5 border-l-2"
                    style={{ color: "var(--text-secondary)", borderLeftColor: "var(--primary-val)" }}
                  >
                    {item.resolution}
                  </p>
                </div>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  );
}
