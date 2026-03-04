import { useEffect } from "react";
import { Link } from "react-router-dom";
import { useLocale } from "../context/LocaleContext";
import LegalLayout from "../components/LegalLayout";

export default function DeleteAccount() {
  const { t } = useLocale();

  useEffect(() => { window.scrollTo(0, 0); }, []);

  return (
    <LegalLayout>
      <h1 className="text-2xl sm:text-3xl font-bold mb-2" style={{ color: "var(--text-primary)" }}>{t.delete_title}</h1>
      <p className="text-xs sm:text-sm mb-6 sm:mb-8" style={{ color: "var(--text-muted)" }}>{t.delete_last_updated}</p>

      <div className="legal-body space-y-4 text-[0.8rem] sm:text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
        <p>{t.delete_intro}</p>

        <h2 className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>{t.delete_steps_title}</h2>
        <ol className="list-decimal pl-6 space-y-2">
          <li>{t.delete_step1}</li>
          <li>{t.delete_step2}</li>
          <li>{t.delete_step3}</li>
          <li>{t.delete_step4}</li>
        </ol>

        <div
          className="rounded-xl p-4 sm:p-5 mt-6 border-l-[3px]"
          style={{ background: "var(--surface-variant)", borderLeftColor: "var(--primary-val)" }}
        >
          <p className="font-semibold mb-2" style={{ color: "var(--text-primary)" }}>{t.delete_alt_title}</p>
          <p>{t.delete_alt_desc}</p>
          <p className="mt-2">
            <strong style={{ color: "var(--text-primary)" }}>Email:</strong>{" "}
            <a href="mailto:suporte@gestaomensal.app" style={{ color: "var(--primary-val)" }}>suporte@gestaomensal.app</a>
          </p>
        </div>

        <h2 className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>{t.delete_data_title}</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>{t.delete_data_deleted_title}</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>{t.delete_data_deleted1}</li>
          <li>{t.delete_data_deleted2}</li>
          <li>{t.delete_data_deleted3}</li>
          <li>{t.delete_data_deleted4}</li>
          <li>{t.delete_data_deleted5}</li>
          <li>{t.delete_data_deleted6}</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>{t.delete_data_retained_title}</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>{t.delete_data_retained1}</li>
          <li>{t.delete_data_retained2}</li>
        </ul>

        <h2 className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>{t.delete_timeline_title}</h2>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>{t.delete_timeline1}</li>
          <li>{t.delete_timeline2}</li>
          <li>{t.delete_timeline3}</li>
        </ul>

        <h2 className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>{t.delete_subscription_title}</h2>
        <p>{t.delete_subscription_desc}</p>

        <div
          className="rounded-xl p-4 sm:p-5 mt-6 border-l-[3px]"
          style={{ background: "var(--surface-variant)", borderLeftColor: "#F59E0B" }}
        >
          <p className="font-semibold mb-2" style={{ color: "var(--text-primary)" }}>{t.delete_important_title}</p>
          <p>{t.delete_important_desc}</p>
        </div>

        <h2 className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>{t.delete_contact_title}</h2>
        <p>{t.delete_contact_desc}</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Email:</strong> <a href="mailto:suporte@gestaomensal.app" style={{ color: "var(--primary-val)" }}>suporte@gestaomensal.app</a></li>
        </ul>
        <p className="mt-4">
          {t.delete_see_also}{" "}
          <Link to="/privacy-policy" style={{ color: "var(--primary-val)" }}>{t.delete_privacy_link}</Link>
        </p>
      </div>
    </LegalLayout>
  );
}
