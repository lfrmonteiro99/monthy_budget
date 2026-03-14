import { useEffect } from "react";
import { useLocale } from "../context/LocaleContext";
import LegalLayout from "../components/LegalLayout";

export default function PrivacyPolicy() {
  const { t } = useLocale();

  useEffect(() => { window.scrollTo(0, 0); }, []);

  return (
    <LegalLayout>
      <h1 className="text-2xl sm:text-3xl font-bold mb-2" style={{ color: "var(--text-primary)" }}>{t.privacy_title}</h1>
      <p className="text-xs sm:text-sm mb-6 sm:mb-8" style={{ color: "var(--text-muted)" }}>{t.privacy_last_updated}</p>

      {/* TOC */}
      <nav
        className="rounded-r-xl pl-4 pr-4 sm:pl-6 sm:pr-6 py-4 sm:py-5 mb-6 sm:mb-8 border-l-[3px]"
        style={{ background: "var(--surface-variant)", borderLeftColor: "var(--primary-val)" }}
        aria-label="Índice"
      >
        <h2 className="text-base font-bold mb-3" style={{ color: "var(--text-primary)" }}>Índice</h2>
        <ol className="list-decimal pl-5 space-y-1.5 text-sm" style={{ color: "var(--text-secondary)" }}>
          <li><a href="#pp-1" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Informações que Recolhemos</a></li>
          <li><a href="#pp-2" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Como Utilizamos as Suas Informações</a></li>
          <li><a href="#pp-3" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Armazenamento e Segurança dos Dados</a></li>
          <li><a href="#pp-4" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Partilha de Dados</a></li>
          <li><a href="#pp-5" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Coach Financeiro com IA</a></li>
          <li><a href="#pp-6" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Publicidade e Plano Gratuito</a></li>
          <li><a href="#pp-7" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Dados de Subscrição e Pagamentos</a></li>
          <li><a href="#pp-8" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Os Seus Direitos (RGPD)</a></li>
          <li><a href="#pp-9" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Retenção de Dados</a></li>
          <li><a href="#pp-10" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Crianças</a></li>
          <li><a href="#pp-11" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Alterações a Esta Política</a></li>
          <li><a href="#pp-12" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Contacto</a></li>
        </ol>
      </nav>

      <div className="legal-body space-y-4 text-[0.8rem] sm:text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
        <p>A aplicação <strong style={{ color: "var(--text-primary)" }}>Gestão Mensal</strong> ("nós", "a App") compromete-se a proteger a privacidade dos seus utilizadores. Esta Política de Privacidade descreve como recolhemos, utilizamos e protegemos as suas informações quando utiliza a nossa aplicação móvel disponível na Google Play Store.</p>

        <h2 id="pp-1" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>1. Informações que Recolhemos</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>1.1 Informações fornecidas pelo utilizador</h3>
        <p>Ao utilizar a App, poderá fornecer-nos as seguintes informações:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Dados de conta:</strong> endereço de email e nome, caso opte por criar uma conta para sincronização entre dispositivos.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Dados financeiros:</strong> rendimentos, despesas, orçamentos e metas de poupança que introduz na App.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Listas de compras:</strong> produtos, quantidades e preços que adiciona às suas listas.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Planos de refeições:</strong> refeições planeadas e preferências alimentares.</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>1.2 Informações recolhidas automaticamente</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Dados do dispositivo:</strong> tipo de dispositivo, versão do sistema operativo e identificadores únicos do dispositivo.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Dados de utilização:</strong> funcionalidades utilizadas, frequência de utilização e interações com a App.</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>1.3 Informações que NÃO recolhemos</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Dados bancários reais ou credenciais de acesso a contas bancárias.</li>
          <li>Números de cartão de crédito ou débito.</li>
          <li>Número de Identificação Fiscal (NIF) — os cálculos de IRS são realizados localmente no dispositivo.</li>
          <li>Localização GPS do utilizador.</li>
        </ul>

        <h2 id="pp-2" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>2. Como Utilizamos as Suas Informações</h2>
        <p>Utilizamos as informações recolhidas para:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Fornecer e manter as funcionalidades da App.</li>
          <li>Sincronizar os seus dados entre dispositivos (quando ativa a sincronização).</li>
          <li>Gerar análises e relatórios financeiros personalizados.</li>
          <li>Fornecer conselhos financeiros através do coach de IA (os dados são processados de forma anonimizada).</li>
          <li>Melhorar e desenvolver novas funcionalidades.</li>
          <li>Enviar notificações e lembretes (apenas com a sua permissão).</li>
        </ul>

        <h2 id="pp-3" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>3. Armazenamento e Segurança dos Dados</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.1 Armazenamento local</h3>
        <p>Os dados financeiros são armazenados primariamente no seu dispositivo, utilizando armazenamento local seguro.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.2 Sincronização na nuvem</h3>
        <p>Caso opte pela sincronização, os seus dados são armazenados em servidores seguros fornecidos pela <strong style={{ color: "var(--text-primary)" }}>Supabase</strong>, com encriptação em trânsito (TLS) e em repouso. Os servidores estão localizados na União Europeia, em conformidade com o RGPD.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.3 Medidas de segurança</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Encriptação de dados em trânsito e em repouso.</li>
          <li>Autenticação segura para acesso à conta.</li>
          <li>Acesso restrito aos dados por parte da equipa de desenvolvimento.</li>
          <li>Auditorias regulares de segurança.</li>
        </ul>

        <h2 id="pp-4" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>4. Partilha de Dados</h2>
        <p><strong style={{ color: "var(--text-primary)" }}>Não vendemos, trocamos ou alugamos</strong> os seus dados pessoais a terceiros. Os seus dados podem ser partilhados apenas nas seguintes circunstâncias:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Agregado familiar:</strong> quando cria ou se junta a um perfil familiar, os dados do orçamento são partilhados com os membros do agregado.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Fornecedores de serviços:</strong> utilizamos serviços de terceiros (Supabase para backend, OpenAI para funcionalidades de IA) que processam dados de acordo com as suas políticas de privacidade e em conformidade com o RGPD.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Obrigação legal:</strong> quando exigido por lei ou ordem judicial.</li>
        </ul>

        <h2 id="pp-5" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>5. Coach Financeiro com IA</h2>
        <p>A funcionalidade de coach financeiro utiliza inteligência artificial para fornecer conselhos personalizados. Para este efeito:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Os seus dados financeiros são enviados de forma anonimizada e agregada ao serviço de IA.</li>
          <li>Não são enviados dados pessoais identificáveis (nome, email, NIF).</li>
          <li>Os dados processados pela IA não são retidos pelo fornecedor do serviço após o processamento.</li>
        </ul>

        <h2 id="pp-6" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>6. Publicidade e Plano Gratuito</h2>
        <p>Os utilizadores do plano Gratuito visualizam anúncios <em>banner</em> na App. Para apresentar anúncios relevantes, poderemos partilhar informações limitadas com parceiros de publicidade:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Dados partilhados:</strong> identificador publicitário do dispositivo (GAID/IDFA), tipo de dispositivo, idioma e país. <strong style={{ color: "var(--text-primary)" }}>Nunca</strong> partilhamos dados financeiros, nomes ou emails com redes de publicidade.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Parceiros:</strong> utilizamos o Google AdMob para a exibição de anúncios, sujeito à <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer" style={{ color: "var(--primary-val)" }}>Política de Privacidade da Google</a>.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Desativação:</strong> pode limitar a personalização de anúncios nas definições do seu dispositivo Android (Definições &gt; Google &gt; Anúncios). Os planos Premium e Família não incluem publicidade.</li>
        </ul>

        <h2 id="pp-7" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>7. Dados de Subscrição e Pagamentos</h2>
        <p>A App oferece planos de subscrição (Premium e Família) processados integralmente pela Google Play Store.</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Dados de pagamento:</strong> todos os pagamentos são processados pela Google. <strong style={{ color: "var(--text-primary)" }}>Não temos acesso</strong> ao número do seu cartão de crédito, conta bancária ou outros dados de pagamento.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Dados que recebemos:</strong> a Google notifica-nos apenas sobre o estado da subscrição (ativa, expirada, cancelada), o tipo de plano e a data de renovação — informações necessárias para ativar as funcionalidades correspondentes.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Período de teste:</strong> ao iniciar um teste gratuito de 21 dias, registamos a data de início para gerir o acesso às funcionalidades. Não são recolhidos dados de pagamento durante o período de teste.</li>
        </ul>

        <h2 id="pp-8" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>8. Os Seus Direitos (RGPD)</h2>
        <p>Enquanto residente na União Europeia, tem os seguintes direitos relativamente aos seus dados pessoais:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Direito de acesso:</strong> solicitar uma cópia dos seus dados pessoais.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Direito de retificação:</strong> corrigir dados incorretos ou incompletos.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Direito ao apagamento:</strong> solicitar a eliminação dos seus dados.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Direito à portabilidade:</strong> exportar os seus dados em formato legível (PDF, CSV).</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Direito de oposição:</strong> opor-se ao processamento dos seus dados.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Direito à limitação:</strong> restringir o processamento dos seus dados.</li>
        </ul>
        <p>Para exercer qualquer destes direitos, contacte-nos através do email indicado na secção de contacto.</p>

        <h2 id="pp-9" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>9. Retenção de Dados</h2>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Os dados locais permanecem no dispositivo até que desinstale a App ou os elimine manualmente.</li>
          <li>Os dados sincronizados na nuvem são retidos enquanto mantiver a sua conta ativa.</li>
          <li>Após eliminação da conta, os seus dados são removidos dos nossos servidores no prazo de 30 dias.</li>
        </ul>

        <h2 id="pp-10" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>10. Crianças</h2>
        <p>A App não é direcionada a crianças com idade inferior a 16 anos. Não recolhemos intencionalmente informações pessoais de crianças. Se tomarmos conhecimento de que recolhemos dados de uma criança menor de 16 anos, tomaremos medidas para eliminar essas informações.</p>

        <h2 id="pp-11" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>11. Alterações a Esta Política</h2>
        <p>Poderemos atualizar esta Política de Privacidade periodicamente. Notificaremos os utilizadores de quaisquer alterações significativas através da App ou por email. A data de "última atualização" no topo desta página indica quando a política foi revista pela última vez.</p>

        <h2 id="pp-12" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>12. Contacto</h2>
        <p>Para questões sobre esta Política de Privacidade ou sobre os seus dados pessoais, contacte-nos:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Email:</strong> suporte@gestaomensal.app</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Responsável pelo tratamento de dados:</strong> Gestão Mensal</li>
        </ul>
      </div>
    </LegalLayout>
  );
}
