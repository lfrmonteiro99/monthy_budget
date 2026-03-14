import { useState } from "react";
import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

export default function Pricing() {
  const { t } = useLocale();
  const [yearly, setYearly] = useState(false);

  const plans = [
    {
      name: t.pricing_free_name,
      price: t.pricing_free_price,
      period: t.pricing_free_period,
      desc: t.pricing_free_desc,
      cta: t.pricing_free_cta,
      popular: false,
      features: [
        t.pricing_free_feat1,
        t.pricing_free_feat2,
        t.pricing_free_feat3,
        t.pricing_free_feat4,
        t.pricing_free_feat5,
      ],
      muted: [4], // index of "Banner ads" — visually muted
    },
    {
      name: t.pricing_premium_name,
      price: yearly ? t.pricing_premium_price_yearly : t.pricing_premium_price_monthly,
      period: yearly ? t.pricing_premium_period_yearly : t.pricing_premium_period_monthly,
      desc: t.pricing_premium_desc,
      cta: t.pricing_premium_cta,
      popular: true,
      features: [
        t.pricing_premium_feat1,
        t.pricing_premium_feat2,
        t.pricing_premium_feat3,
        t.pricing_premium_feat4,
        t.pricing_premium_feat5,
        t.pricing_premium_feat6,
        t.pricing_premium_feat7,
        t.pricing_premium_feat8,
        t.pricing_premium_feat9,
        t.pricing_premium_feat10,
      ],
      muted: [],
    },
    {
      name: t.pricing_family_name,
      price: yearly ? t.pricing_family_price_yearly : t.pricing_family_price_monthly,
      period: yearly ? t.pricing_family_period_yearly : t.pricing_family_period_monthly,
      desc: t.pricing_family_desc,
      cta: t.pricing_family_cta,
      popular: false,
      features: [
        t.pricing_family_feat1,
        t.pricing_family_feat2,
        t.pricing_family_feat3,
        t.pricing_family_feat4,
        t.pricing_family_feat5,
        t.pricing_family_feat6,
        t.pricing_family_feat7,
      ],
      muted: [],
    },
  ];

  return (
    <section className="py-12 sm:py-20" id="precos">
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2
              className="text-2xl sm:text-3xl font-bold mb-3"
              style={{ color: "var(--text-primary)" }}
            >
              {t.pricing_title}
            </h2>
            <p
              className="text-sm sm:text-base max-w-xl mx-auto mb-6"
              style={{ color: "var(--text-secondary)" }}
            >
              {t.pricing_desc}
            </p>

            {/* Monthly / Yearly toggle */}
            <div className="inline-flex items-center gap-3 p-1 rounded-xl" style={{ background: "var(--surface-variant)" }}>
              <button
                onClick={() => setYearly(false)}
                className="px-4 py-2 rounded-lg text-sm font-semibold transition-all border-none cursor-pointer"
                style={{
                  background: !yearly ? "var(--primary-val)" : "transparent",
                  color: !yearly ? "var(--on-primary)" : "var(--text-secondary)",
                }}
              >
                {t.pricing_toggle_monthly}
              </button>
              <button
                onClick={() => setYearly(true)}
                className="px-4 py-2 rounded-lg text-sm font-semibold transition-all border-none cursor-pointer flex items-center gap-2"
                style={{
                  background: yearly ? "var(--primary-val)" : "transparent",
                  color: yearly ? "var(--on-primary)" : "var(--text-secondary)",
                }}
              >
                {t.pricing_toggle_yearly}
                <span
                  className="text-xs font-bold px-2 py-0.5 rounded-full"
                  style={{
                    background: yearly ? "rgba(255,255,255,0.25)" : "var(--primary-light-val)",
                    color: yearly ? "white" : "var(--primary-val)",
                  }}
                >
                  {t.pricing_save_badge}
                </span>
              </button>
            </div>
          </div>
        </AnimatedSection>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 sm:gap-6 items-start">
          {plans.map((plan, i) => (
            <AnimatedSection key={plan.name} delay={i * 0.1}>
              <div
                className="relative rounded-2xl p-6 sm:p-8 border transition-all h-full"
                style={{
                  background: plan.popular
                    ? "linear-gradient(135deg, rgba(59,130,246,0.04), rgba(59,130,246,0.08))"
                    : "var(--surface)",
                  borderColor: plan.popular ? "var(--primary-val)" : "var(--border-card)",
                  boxShadow: plan.popular ? "0 4px 24px rgba(59,130,246,0.12)" : "none",
                }}
              >
                {/* Popular badge */}
                {plan.popular && (
                  <div
                    className="absolute -top-3 left-1/2 -translate-x-1/2 px-4 py-1 rounded-full text-xs font-bold text-white"
                    style={{ background: "linear-gradient(135deg, #3B82F6, #2563EB)" }}
                  >
                    {t.pricing_premium_popular}
                  </div>
                )}

                <div className="mb-4">
                  <h3
                    className="text-lg font-bold mb-1"
                    style={{ color: "var(--text-primary)" }}
                  >
                    {plan.name}
                  </h3>
                  <p
                    className="text-sm mb-4"
                    style={{ color: "var(--text-secondary)" }}
                  >
                    {plan.desc}
                  </p>
                  <div className="flex items-baseline gap-1">
                    <span
                      className="text-3xl sm:text-4xl font-bold"
                      style={{ color: "var(--text-primary)" }}
                    >
                      {plan.price}
                    </span>
                    <span
                      className="text-sm font-medium"
                      style={{ color: "var(--text-muted)" }}
                    >
                      {plan.period}
                    </span>
                  </div>
                </div>

                <a
                  href="#download"
                  className="w-full py-3 rounded-xl font-semibold text-sm no-underline hover:no-underline transition-all hover:-translate-y-0.5 mb-6 min-h-[44px] flex items-center justify-center"
                  style={
                    plan.popular
                      ? {
                          background: "linear-gradient(135deg, #3B82F6, #2563EB)",
                          color: "white",
                          boxShadow: "0 4px 14px rgba(59,130,246,0.35)",
                        }
                      : {
                          background: "var(--primary-light-val)",
                          color: "var(--primary-val)",
                          border: "1px solid var(--primary-val)",
                        }
                  }
                >
                  {plan.cta}
                </a>

                <ul className="space-y-3">
                  {plan.features.map((feat, fi) => (
                    <li
                      key={fi}
                      className="flex items-start gap-2.5 text-sm"
                      style={{
                        color: plan.muted.includes(fi)
                          ? "var(--text-muted)"
                          : "var(--text-secondary)",
                      }}
                    >
                      <svg
                        viewBox="0 0 24 24"
                        width="18"
                        height="18"
                        fill="none"
                        stroke={plan.muted.includes(fi) ? "var(--text-muted)" : "var(--primary-val)"}
                        strokeWidth="2"
                        className="shrink-0 mt-0.5"
                      >
                        {plan.muted.includes(fi) ? (
                          <path d="M5 12h14" />
                        ) : (
                          <path d="m5 12 5 5L20 7" />
                        )}
                      </svg>
                      {feat}
                    </li>
                  ))}
                </ul>
              </div>
            </AnimatedSection>
          ))}
        </div>
      </div>
    </section>
  );
}
