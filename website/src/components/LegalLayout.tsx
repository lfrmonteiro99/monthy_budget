import type { ReactNode } from "react";
import Header from "./Header";
import Footer from "./Footer";

interface Props {
  children: ReactNode;
}

export default function LegalLayout({ children }: Props) {
  return (
    <>
      <Header />
      <main className="py-8 sm:py-16" id="main-content" tabIndex={-1}>
        <div className="max-w-[1140px] mx-auto px-4 sm:px-6">
          <div
            className="max-w-[800px] mx-auto rounded-2xl border p-4 sm:p-6 md:p-12"
            style={{
              background: "var(--surface)",
              borderColor: "var(--border-card)",
            }}
          >
            {children}
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
