import { motion } from "framer-motion";
import { useLocale } from "../context/LocaleContext";

export default function PhoneMockup() {
  const { t } = useLocale();

  return (
    <section className="pb-16 flex flex-col items-center justify-center">
      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.5 }}
        className="relative flex flex-col items-center"
      >
        {/* Glow */}
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[320px] h-[600px] rounded-[48px] animate-pulse"
          style={{ background: "radial-gradient(ellipse, rgba(59,130,246,0.15) 0%, transparent 70%)" }}
        />

        {/* Phone */}
        <div
          className="w-[280px] h-[560px] rounded-[36px] border-[3px] overflow-hidden relative z-[2]"
          style={{
            background: "var(--surface)",
            borderColor: "var(--border)",
            boxShadow: "var(--shadow-xl)"
          }}
        >
          {/* Notch */}
          <div className="w-[120px] h-7 rounded-b-2xl mx-auto relative z-[2]" style={{ background: "var(--bg)" }} />

          {/* Screen */}
          <div className="px-4 py-4 h-[calc(100%-28px)] flex flex-col gap-3 overflow-hidden">
            <div className="text-center py-2">
              <h3 className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>{t.mockup_title}</h3>
              <p className="text-[0.7rem]" style={{ color: "var(--text-secondary)" }}>Março 2026</p>
            </div>

            <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
              <div className="text-[0.65rem] font-semibold uppercase tracking-wider mb-1.5" style={{ color: "var(--text-secondary)" }}>{t.mockup_net_label}</div>
              <div className="text-xl font-bold" style={{ color: "var(--primary-val)" }}>€ 1.850,00</div>
            </div>

            <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
              <div className="text-[0.65rem] font-semibold uppercase tracking-wider mb-1.5" style={{ color: "var(--text-secondary)" }}>{t.mockup_expenses_label}</div>
              <div className="text-xl font-bold text-red-500">€ 1.230,45</div>
            </div>

            <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
              <div className="text-[0.65rem] font-semibold uppercase tracking-wider mb-1.5" style={{ color: "var(--text-secondary)" }}>{t.mockup_savings_label}</div>
              <div className="text-xl font-bold text-emerald-500">€ 619,55</div>
            </div>

            <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
              <div className="text-[0.65rem] font-semibold uppercase tracking-wider mb-1.5" style={{ color: "var(--text-secondary)" }}>{t.mockup_trend_label}</div>
              <div className="flex gap-1.5 items-end h-[60px] pt-2">
                {[30, 55, 20, 80, 45, 65].map((h, i) => (
                  <motion.div
                    key={i}
                    className="flex-1 rounded-t"
                    style={{
                      height: `${h}%`,
                      background: i === 3 ? "var(--primary-val)" : "var(--primary-light-val)"
                    }}
                    initial={{ scaleY: 0 }}
                    animate={{ scaleY: 1 }}
                    transition={{ delay: 0.6 + i * 0.1, duration: 0.4, ease: "easeOut" }}
                  />
                ))}
              </div>
            </div>

            <div className="mt-auto flex justify-around py-2.5 border-t" style={{ borderColor: "var(--border-card)" }}>
              {[true, false, false, false, false].map((active, i) => (
                <div
                  key={i}
                  className="rounded-full"
                  style={{
                    width: active ? 24 : 8,
                    height: 8,
                    borderRadius: active ? 4 : "50%",
                    background: active ? "var(--primary-val)" : "var(--text-muted)"
                  }}
                />
              ))}
            </div>
          </div>
        </div>

        {/* Floating cards */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8, duration: 0.5 }}
          className="absolute top-[15%] right-[-60px] z-[3] hidden sm:flex items-center gap-2 rounded-full px-4 py-2 text-xs font-semibold border"
          style={{
            background: "var(--surface)",
            borderColor: "var(--border-card)",
            color: "var(--text-primary)",
            boxShadow: "var(--shadow-lg)"
          }}
        >
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" style={{ color: "var(--primary-val)" }}>
            <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
          </svg>
          {t.float1}
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.2, duration: 0.5 }}
          className="absolute top-[50%] left-[-70px] z-[3] hidden sm:flex items-center gap-2 rounded-full px-4 py-2 text-xs font-semibold border"
          style={{
            background: "var(--surface)",
            borderColor: "var(--border-card)",
            color: "var(--text-primary)",
            boxShadow: "var(--shadow-lg)"
          }}
        >
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" style={{ color: "var(--primary-val)" }}>
            <path d="M22 12h-4l-3 9L9 3l-3 9H2" />
          </svg>
          {t.float2}
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.6, duration: 0.5 }}
          className="absolute bottom-[18%] right-[-50px] z-[3] hidden sm:flex items-center gap-2 rounded-full px-4 py-2 text-xs font-semibold border"
          style={{
            background: "var(--surface)",
            borderColor: "var(--border-card)",
            color: "var(--text-primary)",
            boxShadow: "var(--shadow-lg)"
          }}
        >
          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" style={{ color: "var(--primary-val)" }}>
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
          </svg>
          {t.float3}
        </motion.div>

        <span className="mt-4 text-sm font-medium z-[2]" style={{ color: "var(--text-muted)" }}>
          {t.mockup_label}
        </span>
      </motion.div>
    </section>
  );
}
