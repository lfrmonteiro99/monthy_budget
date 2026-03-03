import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

const icons = [
  <svg key="1" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/></svg>,
  <svg key="2" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>,
  <svg key="3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>,
  <svg key="4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><circle cx="15.5" cy="8.5" r="1.5"/><circle cx="15.5" cy="15.5" r="1.5"/><circle cx="8.5" cy="15.5" r="1.5"/></svg>,
];

export default function TrustBar() {
  const { t } = useLocale();
  const items = [t.trust1, t.trust2, t.trust3, t.trust4];

  return (
    <section className="py-8 border-b" style={{ borderBottomColor: "var(--border-card)" }}>
      <div className="max-w-[1140px] mx-auto px-6">
        <AnimatedSection>
          <div className="flex justify-center items-center gap-12 flex-wrap">
            {items.map((item, i) => (
              <div key={i} className="flex items-center gap-2.5 text-sm font-medium" style={{ color: "var(--text-secondary)" }}>
                <span className="w-5 h-5 shrink-0" style={{ color: "var(--primary-val)" }}>{icons[i]}</span>
                {item}
              </div>
            ))}
          </div>
        </AnimatedSection>
      </div>
    </section>
  );
}
