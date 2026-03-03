import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

export default function FAQ() {
  const { t } = useLocale();
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  const faqs = [
    { q: t.faq1_q, a: t.faq1_a },
    { q: t.faq2_q, a: t.faq2_a },
    { q: t.faq3_q, a: t.faq3_a },
    { q: t.faq4_q, a: t.faq4_a },
    { q: t.faq5_q, a: t.faq5_a },
    { q: t.faq6_q, a: t.faq6_a },
  ];

  return (
    <section className="py-12 sm:py-20">
      <div className="max-w-[720px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>
              {t.faq_title}
            </h2>
          </div>
        </AnimatedSection>

        <div className="space-y-3">
          {faqs.map((faq, i) => (
            <AnimatedSection key={i} delay={i * 0.05}>
              <div
                className="rounded-2xl border overflow-hidden transition-colors"
                style={{
                  background: "var(--surface)",
                  borderColor: openIndex === i ? "var(--primary-val)" : "var(--border-card)",
                }}
              >
                <button
                  onClick={() => setOpenIndex(openIndex === i ? null : i)}
                  className="w-full flex items-center justify-between gap-4 p-4 sm:p-5 text-left border-none cursor-pointer bg-transparent"
                >
                  <span
                    className="text-sm sm:text-base font-semibold"
                    style={{ color: "var(--text-primary)" }}
                  >
                    {faq.q}
                  </span>
                  <motion.div
                    animate={{ rotate: openIndex === i ? 180 : 0 }}
                    transition={{ duration: 0.2 }}
                    className="shrink-0 w-5 h-5"
                    style={{ color: "var(--text-muted)" }}
                  >
                    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="6 9 12 15 18 9" />
                    </svg>
                  </motion.div>
                </button>

                <AnimatePresence>
                  {openIndex === i && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: "auto", opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.2 }}
                    >
                      <p
                        className="text-sm leading-relaxed px-4 sm:px-5 pb-4 sm:pb-5"
                        style={{ color: "var(--text-secondary)" }}
                      >
                        {faq.a}
                      </p>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  );
}
