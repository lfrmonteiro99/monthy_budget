import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useLocale } from "../context/LocaleContext";
import AnimatedSection from "./AnimatedSection";

const screenIcons = [
  <svg key="s1" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>,
  <svg key="s2" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>,
  <svg key="s3" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>,
  <svg key="s4" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2"><path d="M3 2v7c0 1.1.9 2 2 2h4a2 2 0 0 0 2-2V2"/><path d="M7 2v20"/><path d="M21 15V2v0a5 5 0 0 0-5 5v6c0 1.1.9 2 2 2h3Zm0 0v7"/></svg>,
  <svg key="s5" viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 2a8 8 0 0 0-8 8c0 6 8 12 8 12s8-6 8-12a8 8 0 0 0-8-8z"/><circle cx="12" cy="10" r="3"/></svg>,
];

// Mockup content for each screen
function DashboardMockup() {
  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>Março 2026</span>
        <span className="text-xs px-2 py-1 rounded-full" style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}>Ativo</span>
      </div>
      <div className="rounded-xl p-4" style={{ background: "var(--surface-variant)" }}>
        <div className="text-xs font-semibold uppercase tracking-wider mb-1" style={{ color: "var(--text-muted)" }}>Rendimento</div>
        <div className="text-2xl font-bold" style={{ color: "var(--primary-val)" }}>€ 1.850,00</div>
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
          <div className="text-xs font-semibold uppercase mb-1" style={{ color: "var(--text-muted)" }}>Despesas</div>
          <div className="text-lg font-bold text-red-500">€ 1.230</div>
        </div>
        <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
          <div className="text-xs font-semibold uppercase mb-1" style={{ color: "var(--text-muted)" }}>Poupança</div>
          <div className="text-lg font-bold text-emerald-500">€ 619</div>
        </div>
      </div>
      <div className="rounded-xl p-3" style={{ background: "var(--surface-variant)" }}>
        <div className="flex gap-1.5 items-end h-16">
          {[30, 55, 20, 80, 45, 65, 50].map((h, i) => (
            <motion.div
              key={i}
              className="flex-1 rounded-t"
              style={{ height: `${h}%`, background: i === 3 ? "var(--primary-val)" : "var(--primary-light-val)" }}
              initial={{ scaleY: 0 }}
              animate={{ scaleY: 1 }}
              transition={{ delay: i * 0.08, duration: 0.3 }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

function SupermarketMockup() {
  const items = [
    { name: "Leite Meio-Gordo", price: "€ 0,89", cat: "Laticínios" },
    { name: "Pão de Forma", price: "€ 1,49", cat: "Padaria" },
    { name: "Frango Inteiro", price: "€ 4,99", cat: "Carnes" },
    { name: "Arroz Carolino", price: "€ 1,29", cat: "Mercearia" },
  ];
  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>Produtos</span>
        <span className="text-xs" style={{ color: "var(--text-muted)" }}>248 itens</span>
      </div>
      {items.map((item, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: i * 0.1 }}
          className="flex justify-between items-center p-3 rounded-xl"
          style={{ background: "var(--surface-variant)" }}
        >
          <div>
            <div className="text-sm font-semibold" style={{ color: "var(--text-primary)" }}>{item.name}</div>
            <div className="text-xs" style={{ color: "var(--text-muted)" }}>{item.cat}</div>
          </div>
          <span className="text-sm font-bold" style={{ color: "var(--primary-val)" }}>{item.price}</span>
        </motion.div>
      ))}
    </div>
  );
}

function ShoppingListMockup() {
  const items = [
    { name: "Leite (x2)", checked: true },
    { name: "Ovos (dúzia)", checked: true },
    { name: "Frango", checked: false },
    { name: "Legumes", checked: false },
  ];
  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>Lista Semanal</span>
        <span className="text-xs px-2 py-1 rounded-full" style={{ background: "var(--primary-light-val)", color: "var(--primary-val)" }}>2/4</span>
      </div>
      <div className="rounded-xl p-3 text-center" style={{ background: "var(--surface-variant)" }}>
        <div className="text-xs font-semibold uppercase mb-1" style={{ color: "var(--text-muted)" }}>Total Estimado</div>
        <div className="text-xl font-bold" style={{ color: "var(--primary-val)" }}>€ 47,80</div>
      </div>
      {items.map((item, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: i * 0.08 }}
          className="flex items-center gap-3 p-3 rounded-xl"
          style={{ background: "var(--surface-variant)" }}
        >
          <div
            className="w-5 h-5 rounded border-2 flex items-center justify-center shrink-0"
            style={{
              borderColor: item.checked ? "var(--primary-val)" : "var(--border)",
              background: item.checked ? "var(--primary-val)" : "transparent"
            }}
          >
            {item.checked && (
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="3"><path d="M20 6L9 17l-5-5"/></svg>
            )}
          </div>
          <span className="text-sm" style={{ color: "var(--text-primary)", textDecoration: item.checked ? "line-through" : "none", opacity: item.checked ? 0.5 : 1 }}>
            {item.name}
          </span>
        </motion.div>
      ))}
    </div>
  );
}

function MealsMockup() {
  const days = ["Seg", "Ter", "Qua", "Qui", "Sex"];
  const meals = ["Sopa + Frango grelhado", "Massa Carbonara", "Arroz de pato", "Bacalhau à Brás", "Pizza caseira"];
  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>Plano Semanal</span>
        <span className="text-xs" style={{ color: "var(--text-muted)" }}>Semana 10</span>
      </div>
      {days.map((day, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0, x: -10 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: i * 0.08 }}
          className="flex items-center gap-3 p-3 rounded-xl"
          style={{ background: "var(--surface-variant)" }}
        >
          <span className="text-xs font-bold w-8 shrink-0" style={{ color: "var(--primary-val)" }}>{day}</span>
          <span className="text-sm" style={{ color: "var(--text-primary)" }}>{meals[i]}</span>
        </motion.div>
      ))}
    </div>
  );
}

function CoachMockup() {
  return (
    <div className="space-y-3">
      <div className="flex justify-between items-center">
        <span className="text-sm font-bold" style={{ color: "var(--text-primary)" }}>Coach IA</span>
        <span className="text-xs px-2 py-1 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-900 dark:text-emerald-300">Online</span>
      </div>
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="rounded-xl p-4"
        style={{ background: "var(--primary-light-val)" }}
      >
        <p className="text-sm leading-relaxed" style={{ color: "var(--text-primary)" }}>
          Olá Maria! Este mês poupou 15% mais que o mês anterior. Continuar a cozinhar em casa ajudou bastante.
        </p>
      </motion.div>
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="rounded-xl p-4 border"
        style={{ background: "var(--surface)", borderColor: "var(--border-card)" }}
      >
        <p className="text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
          Sugestão: considere criar um fundo de emergência com os €180 poupados.
        </p>
      </motion.div>
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.5 }}
        className="flex gap-2"
      >
        <div className="flex-1 text-center p-3 rounded-xl" style={{ background: "var(--surface-variant)" }}>
          <div className="text-lg font-bold text-emerald-500">+15%</div>
          <div className="text-xs" style={{ color: "var(--text-muted)" }}>vs. mês anterior</div>
        </div>
        <div className="flex-1 text-center p-3 rounded-xl" style={{ background: "var(--surface-variant)" }}>
          <div className="text-lg font-bold" style={{ color: "var(--primary-val)" }}>€ 180</div>
          <div className="text-xs" style={{ color: "var(--text-muted)" }}>poupados</div>
        </div>
      </motion.div>
    </div>
  );
}

const mockups = [DashboardMockup, SupermarketMockup, ShoppingListMockup, MealsMockup, CoachMockup];

export default function Screens() {
  const { t } = useLocale();
  const [active, setActive] = useState(0);
  const [touchStart, setTouchStart] = useState(0);

  const screens = [
    { title: t.screen1_title, desc: t.screen1_desc },
    { title: t.screen2_title, desc: t.screen2_desc },
    { title: t.screen3_title, desc: t.screen3_desc },
    { title: t.screen4_title, desc: t.screen4_desc },
    { title: t.screen5_title, desc: t.screen5_desc },
  ];

  const ActiveMockup = mockups[active];

  const handleSwipe = (endX: number) => {
    const diff = touchStart - endX;
    if (Math.abs(diff) > 50) {
      if (diff > 0 && active < screens.length - 1) setActive(active + 1);
      if (diff < 0 && active > 0) setActive(active - 1);
    }
  };

  return (
    <section className="py-12 sm:py-20" id="ecras" style={{ background: "var(--surface-variant)" }}>
      <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
        <AnimatedSection>
          <div className="text-center mb-8 sm:mb-12">
            <h2 className="text-2xl sm:text-3xl font-bold mb-3" style={{ color: "var(--text-primary)" }}>{t.screens_title}</h2>
            <p className="text-sm sm:text-base max-w-xl mx-auto" style={{ color: "var(--text-secondary)" }}>{t.screens_desc}</p>
          </div>
        </AnimatedSection>

        <AnimatedSection delay={0.1}>
          <div className="max-w-[900px] mx-auto">
            {/* Mobile: horizontal scrollable tabs */}
            <div className="flex lg:hidden gap-2 overflow-x-auto pb-3 mb-4 -mx-4 px-4 scrollbar-hide">
              {screens.map((screen, i) => (
                <button
                  key={i}
                  onClick={() => setActive(i)}
                  className="flex items-center gap-2.5 px-4 py-3 rounded-2xl text-left transition-all cursor-pointer border-none whitespace-nowrap shrink-0"
                  style={{
                    background: active === i ? "var(--surface)" : "transparent",
                    boxShadow: active === i ? "var(--shadow-md)" : "none",
                    minHeight: "48px",
                  }}
                >
                  <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 transition-colors"
                    style={{
                      background: active === i ? "var(--primary-light-val)" : "transparent",
                      color: active === i ? "var(--primary-val)" : "var(--text-muted)",
                    }}
                  >
                    {screenIcons[i]}
                  </div>
                  <span
                    className="text-sm font-bold transition-colors"
                    style={{ color: active === i ? "var(--text-primary)" : "var(--text-secondary)" }}
                  >
                    {screen.title}
                  </span>
                </button>
              ))}
            </div>

            {/* Mobile: active screen description */}
            <p className="lg:hidden text-sm text-center mb-5 leading-relaxed px-2" style={{ color: "var(--text-muted)" }}>
              {screens[active].desc}
            </p>

            <div className="grid grid-cols-1 lg:grid-cols-[300px_1fr] gap-8">
              {/* Desktop: left sidebar - hidden on mobile */}
              <div className="hidden lg:flex flex-col gap-2">
                {screens.map((screen, i) => (
                  <button
                    key={i}
                    onClick={() => setActive(i)}
                    className="flex items-center gap-4 p-4 rounded-2xl text-left transition-all cursor-pointer border-none w-full"
                    style={{
                      background: active === i ? "var(--surface)" : "transparent",
                      boxShadow: active === i ? "var(--shadow-md)" : "none",
                    }}
                  >
                    <div
                      className="w-14 h-14 rounded-2xl flex items-center justify-center shrink-0 transition-colors"
                      style={{
                        background: active === i ? "var(--primary-light-val)" : "transparent",
                        color: active === i ? "var(--primary-val)" : "var(--text-muted)",
                      }}
                    >
                      {screenIcons[i]}
                    </div>
                    <div>
                      <h3
                        className="text-base font-bold mb-0.5 transition-colors"
                        style={{ color: active === i ? "var(--text-primary)" : "var(--text-secondary)" }}
                      >
                        {screen.title}
                      </h3>
                      <p className="text-xs leading-relaxed" style={{ color: "var(--text-muted)" }}>{screen.desc}</p>
                    </div>
                    {active === i && (
                      <motion.div
                        layoutId="screen-indicator"
                        className="ml-auto w-1.5 h-10 rounded-full shrink-0"
                        style={{ background: "var(--primary-val)" }}
                      />
                    )}
                  </button>
                ))}
              </div>

              {/* Phone mockup preview */}
              <div
                className="flex justify-center"
                onTouchStart={(e) => setTouchStart(e.touches[0].clientX)}
                onTouchEnd={(e) => handleSwipe(e.changedTouches[0].clientX)}
              >
                <div
                  className="w-[280px] sm:w-[300px] rounded-[36px] border-[3px] overflow-hidden relative"
                  style={{
                    background: "var(--surface)",
                    borderColor: "var(--border)",
                    boxShadow: "var(--shadow-xl)"
                  }}
                >
                  <div className="w-[120px] h-7 rounded-b-2xl mx-auto" style={{ background: "var(--bg)" }} />

                  <div className="px-4 py-4 min-h-[380px] sm:min-h-[400px]">
                    <AnimatePresence mode="wait">
                      <motion.div
                        key={active}
                        initial={{ opacity: 0, y: 12 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: -12 }}
                        transition={{ duration: 0.25 }}
                      >
                        <ActiveMockup />
                      </motion.div>
                    </AnimatePresence>
                  </div>

                  <div className="flex justify-around py-3 border-t mx-4 mb-4" style={{ borderColor: "var(--border-card)" }}>
                    {screens.map((_, i) => (
                      <button
                        key={i}
                        onClick={() => setActive(i)}
                        className="border-none bg-transparent cursor-pointer p-2.5 flex items-center justify-center"
                      >
                        <div
                          className="transition-all"
                          style={{
                            width: active === i ? 24 : 8,
                            height: 8,
                            borderRadius: active === i ? 4 : "50%",
                            background: active === i ? "var(--primary-val)" : "var(--text-muted)"
                          }}
                        />
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </AnimatedSection>
      </div>
    </section>
  );
}
