import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { HashRouter, Routes, Route } from "react-router-dom";
import { ThemeProvider } from "./context/ThemeContext";
import { LocaleProvider } from "./context/LocaleContext";
import App from "./App";
import PrivacyPolicy from "./pages/PrivacyPolicy";
import TermsOfUse from "./pages/TermsOfUse";
import DeleteAccount from "./pages/DeleteAccount";
import "./index.css";

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <ThemeProvider>
      <LocaleProvider>
        <HashRouter>
          <Routes>
            <Route path="/" element={<App />} />
            <Route path="/privacy-policy" element={<PrivacyPolicy />} />
            <Route path="/terms-of-use" element={<TermsOfUse />} />
            <Route path="/delete-account" element={<DeleteAccount />} />
          </Routes>
        </HashRouter>
      </LocaleProvider>
    </ThemeProvider>
  </StrictMode>
);
