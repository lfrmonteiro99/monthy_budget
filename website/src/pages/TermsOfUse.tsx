import { useEffect } from "react";
import { Link } from "react-router-dom";
import { useLocale } from "../context/LocaleContext";
import LegalLayout from "../components/LegalLayout";

export default function TermsOfUse() {
  const { t } = useLocale();

  useEffect(() => { window.scrollTo(0, 0); }, []);

  return (
    <LegalLayout>
      <h1 className="text-2xl sm:text-3xl font-bold mb-2" style={{ color: "var(--text-primary)" }}>{t.terms_title}</h1>
      <p className="text-xs sm:text-sm mb-6 sm:mb-8" style={{ color: "var(--text-muted)" }}>{t.terms_last_updated}</p>

      {/* TOC */}
      <nav
        className="rounded-r-xl pl-4 pr-4 sm:pl-6 sm:pr-6 py-4 sm:py-5 mb-6 sm:mb-8 border-l-[3px]"
        style={{ background: "var(--surface-variant)", borderLeftColor: "var(--primary-val)" }}
        aria-label="Índice"
      >
        <h2 className="text-base font-bold mb-3" style={{ color: "var(--text-primary)" }}>Índice</h2>
        <ol className="list-decimal pl-5 space-y-1.5 text-sm" style={{ color: "var(--text-secondary)" }}>
          <li><a href="#tu-1" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Aceitação dos Termos</a></li>
          <li><a href="#tu-2" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Descrição do Serviço</a></li>
          <li><a href="#tu-3" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Planos, Subscrições e Pagamentos</a></li>
          <li><a href="#tu-4" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Elegibilidade</a></li>
          <li><a href="#tu-5" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Conta de Utilizador</a></li>
          <li><a href="#tu-6" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Utilização Permitida</a></li>
          <li><a href="#tu-7" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Dados Financeiros e Isenção de Responsabilidade</a></li>
          <li><a href="#tu-8" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Propriedade Intelectual</a></li>
          <li><a href="#tu-9" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Conteúdo do Utilizador</a></li>
          <li><a href="#tu-10" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Disponibilidade do Serviço</a></li>
          <li><a href="#tu-11" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Limitação de Responsabilidade</a></li>
          <li><a href="#tu-12" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Atualizações e Modificações</a></li>
          <li><a href="#tu-13" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Rescisão</a></li>
          <li><a href="#tu-14" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Lei Aplicável e Resolução de Litígios</a></li>
          <li><a href="#tu-15" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Disposições Gerais</a></li>
          <li><a href="#tu-16" className="no-underline hover:underline" style={{ color: "var(--text-secondary)" }}>Contacto</a></li>
        </ol>
      </nav>

      <div className="legal-body space-y-4 text-[0.8rem] sm:text-sm leading-relaxed" style={{ color: "var(--text-secondary)" }}>
        <p>Bem-vindo à <strong style={{ color: "var(--text-primary)" }}>Gestão Mensal</strong>. Ao descarregar, instalar ou utilizar a nossa aplicação móvel ("App"), concorda com os presentes Termos de Utilização ("Termos"). Leia-os cuidadosamente antes de utilizar a App.</p>

        <h2 id="tu-1" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>1. Aceitação dos Termos</h2>
        <p>Ao aceder ou utilizar a App, confirma que leu, compreendeu e aceita ficar vinculado a estes Termos. Se não concordar com alguma parte destes Termos, não deverá utilizar a App.</p>

        <h2 id="tu-2" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>2. Descrição do Serviço</h2>
        <p>A Gestão Mensal é uma aplicação de gestão de orçamento mensal que oferece:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Planeamento e acompanhamento de receitas e despesas mensais.</li>
          <li>Cálculo automático de IRS com base nas tabelas de retenção na fonte portuguesas.</li>
          <li>Gestão de listas de compras com preços de supermercado.</li>
          <li>Planeamento de refeições com otimização de custos.</li>
          <li>Coach financeiro baseado em inteligência artificial.</li>
          <li>Sincronização de dados entre dispositivos e membros do agregado familiar.</li>
          <li>Exportação de relatórios em PDF e CSV.</li>
        </ul>

        <h2 id="tu-3" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>3. Planos, Subscrições e Pagamentos</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.1 Planos disponíveis</h3>
        <p>A App oferece os seguintes planos:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Gratuito (pós-teste):</strong> calculadora de orçamento (até 5 categorias), registo de despesas do mês atual, 1 objetivo de poupança, lista de compras local e anúncios banner.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Premium — €3,99/mês ou €29,99/ano:</strong> categorias e histórico ilimitados, Coach Financeiro com IA, plano de refeições com receitas IA, sincronização da lista de compras em tempo real, exportação PDF/CSV, lembretes de contas e sem anúncios.</li>
          <li><strong style={{ color: "var(--text-primary)" }}>Família — €6,99/mês ou €49,99/ano:</strong> tudo do Premium, mais partilha familiar (até 6 pessoas), simulador de impostos multi-país, índice de stress e sequências, relatórios de fim de mês, dashboard personalizável e todos os temas de cores.</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.2 Período de teste gratuito</h3>
        <p>Ao instalar a App, tem acesso a um período de teste gratuito de 14 dias com todas as funcionalidades Premium. Durante o teste:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Não é necessário cartão de crédito nem dados de pagamento.</li>
          <li>O teste termina automaticamente ao fim de 14 dias.</li>
          <li>Após o termo do teste, a App transita para o plano Gratuito, a menos que subscreva um plano pago.</li>
          <li>Os dados criados durante o teste são mantidos, mas o acesso a funcionalidades exclusivas dos planos pagos será limitado.</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.3 Faturação e renovação</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Todos os pagamentos são processados pela <strong style={{ color: "var(--text-primary)" }}>Google Play Store</strong>. Não recolhemos nem armazenamos dados de cartão de crédito ou outros meios de pagamento.</li>
          <li>As subscrições são renovadas automaticamente no final de cada período (mensal ou anual), salvo cancelamento pelo utilizador.</li>
          <li>A renovação é cobrada até 24 horas antes do fim do período em curso.</li>
          <li>Os preços podem variar por país e incluem impostos aplicáveis conforme determinado pela Google Play.</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.4 Cancelamento</h3>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Pode cancelar a subscrição a qualquer momento através da Google Play Store (Definições &gt; Subscrições).</li>
          <li>Após cancelamento, mantém o acesso às funcionalidades pagas até ao fim do período já faturado.</li>
          <li>Depois desse período, a App transita para o plano Gratuito.</li>
          <li>Os seus dados não são eliminados com o cancelamento — continuam disponíveis no plano Gratuito (com as respetivas limitações de acesso).</li>
        </ul>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.5 Reembolsos</h3>
        <p>Os reembolsos são geridos de acordo com a <a href="https://support.google.com/googleplay/answer/2479637" target="_blank" rel="noopener noreferrer" style={{ color: "var(--primary-val)" }}>política de reembolsos da Google Play</a>. Para solicitar um reembolso, contacte o suporte da Google Play ou, em alternativa, contacte-nos diretamente.</p>

        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>3.6 Alteração de preços</h3>
        <p>Reservamo-nos o direito de alterar os preços dos planos. Qualquer alteração será comunicada com pelo menos 30 dias de antecedência e só se aplicará ao período de faturação seguinte. Se não concordar com a alteração, pode cancelar antes da renovação.</p>

        <h2 id="tu-4" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>4. Elegibilidade</h2>
        <p>Para utilizar a App, deve:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Ter pelo menos 16 anos de idade.</li>
          <li>Ter capacidade legal para celebrar contratos vinculativos.</li>
          <li>Não estar impedido de utilizar a App ao abrigo das leis aplicáveis.</li>
        </ul>

        <h2 id="tu-5" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>5. Conta de Utilizador</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>5.1 Criação de conta</h3>
        <p>Algumas funcionalidades da App (como sincronização e partilha familiar) requerem a criação de uma conta. É responsável por manter a confidencialidade das suas credenciais de acesso.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>5.2 Responsabilidade pela conta</h3>
        <p>É responsável por todas as atividades que ocorram na sua conta. Deve notificar-nos imediatamente caso suspeite de qualquer utilização não autorizada.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>5.3 Eliminação da conta</h3>
        <p>Pode solicitar a eliminação da sua conta a qualquer momento. Após a eliminação, os seus dados serão removidos dos nossos servidores no prazo de 30 dias, de acordo com a nossa <Link to="/privacy-policy" style={{ color: "var(--primary-val)" }}>Política de Privacidade</Link>.</p>

        <h2 id="tu-6" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>6. Utilização Permitida</h2>
        <p>Ao utilizar a App, compromete-se a:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Utilizar a App apenas para fins pessoais e não comerciais.</li>
          <li>Fornecer informações verdadeiras e precisas.</li>
          <li>Não tentar aceder a funcionalidades ou dados que não lhe pertençam.</li>
          <li>Não utilizar a App para atividades ilegais ou fraudulentas.</li>
          <li>Não copiar, modificar, distribuir ou fazer engenharia reversa da App.</li>
          <li>Não sobrecarregar ou interferir com o funcionamento da App ou dos seus servidores.</li>
        </ul>

        <h2 id="tu-7" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>7. Dados Financeiros e Isenção de Responsabilidade</h2>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>7.1 Caráter informativo</h3>
        <p>A App é uma ferramenta de gestão de orçamento pessoal. As informações e cálculos apresentados (incluindo cálculos de IRS) têm caráter <strong style={{ color: "var(--text-primary)" }}>meramente informativo e indicativo</strong>, não constituindo aconselhamento financeiro, fiscal ou legal profissional.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>7.2 Tabelas de IRS</h3>
        <p>Os cálculos de IRS são baseados nas tabelas de retenção na fonte publicadas pela Autoridade Tributária. Embora façamos o nosso melhor para manter os dados atualizados, <strong style={{ color: "var(--text-primary)" }}>não garantimos a exatidão absoluta</strong> dos cálculos. Para questões fiscais definitivas, consulte um profissional qualificado ou a Autoridade Tributária.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>7.3 Coach financeiro com IA</h3>
        <p>Os conselhos fornecidos pelo coach financeiro baseado em IA são sugestões geradas automaticamente e <strong style={{ color: "var(--text-primary)" }}>não substituem o aconselhamento financeiro profissional</strong>. As decisões financeiras baseadas nas sugestões da App são da exclusiva responsabilidade do utilizador.</p>
        <h3 className="text-base font-semibold mt-6 mb-2" style={{ color: "var(--text-primary)" }}>7.4 Preços de supermercado</h3>
        <p>Os preços de produtos de supermercado apresentados na App são indicativos e podem não refletir os preços praticados no momento da compra. Verifique sempre os preços no ponto de venda.</p>

        <h2 id="tu-8" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>8. Propriedade Intelectual</h2>
        <p>A App, incluindo o seu design, código, funcionalidades, conteúdo e marcas, é propriedade da Gestão Mensal e está protegida por leis de propriedade intelectual. Não lhe é concedido qualquer direito sobre a propriedade intelectual da App, exceto o direito de utilização pessoal conforme descrito nestes Termos.</p>

        <h2 id="tu-9" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>9. Conteúdo do Utilizador</h2>
        <p>Retém todos os direitos sobre os dados e conteúdo que introduz na App. Ao utilizar funcionalidades de sincronização, concede-nos uma licença limitada para armazenar e processar esses dados exclusivamente para a prestação do serviço.</p>

        <h2 id="tu-10" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>10. Disponibilidade do Serviço</h2>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Não garantimos que a App estará disponível ininterruptamente ou sem erros.</li>
          <li>Reservamo-nos o direito de suspender ou descontinuar o serviço (ou parte dele) a qualquer momento, com aviso prévio razoável quando possível.</li>
          <li>Poderemos realizar manutenções que impliquem indisponibilidade temporária da sincronização.</li>
        </ul>

        <h2 id="tu-11" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>11. Limitação de Responsabilidade</h2>
        <p>Na máxima medida permitida pela lei aplicável:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>A App é fornecida "tal como está" e "conforme disponível".</li>
          <li>Não nos responsabilizamos por quaisquer danos diretos, indiretos, incidentais, especiais ou consequenciais resultantes da utilização ou incapacidade de utilização da App.</li>
          <li>Não nos responsabilizamos por decisões financeiras tomadas com base nas informações fornecidas pela App.</li>
          <li>Não nos responsabilizamos por perda de dados resultante de falhas no dispositivo do utilizador.</li>
        </ul>

        <h2 id="tu-12" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>12. Atualizações e Modificações</h2>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Poderemos lançar atualizações para corrigir erros, melhorar funcionalidades ou cumprir requisitos legais.</li>
          <li>Algumas atualizações podem ser necessárias para continuar a utilizar a App.</li>
          <li>Reservamo-nos o direito de alterar estes Termos a qualquer momento. Notificaremos os utilizadores de alterações significativas.</li>
        </ul>

        <h2 id="tu-13" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>13. Rescisão</h2>
        <p>Podemos suspender ou terminar o seu acesso à App se:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Violar estes Termos de Utilização.</li>
          <li>Utilizar a App de forma abusiva ou prejudicial.</li>
          <li>For necessário por motivos legais ou de segurança.</li>
        </ul>
        <p>Pode deixar de utilizar a App a qualquer momento, desinstalando-a e, se aplicável, eliminando a sua conta.</p>

        <h2 id="tu-14" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>14. Lei Aplicável e Resolução de Litígios</h2>
        <p>Estes Termos são regidos pela legislação portuguesa. Qualquer litígio será submetido à jurisdição exclusiva dos tribunais portugueses competentes, sem prejuízo dos direitos que lhe assistam enquanto consumidor ao abrigo da legislação da União Europeia.</p>

        <h2 id="tu-15" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>15. Disposições Gerais</h2>
        <ul className="list-disc pl-6 space-y-1.5">
          <li>Se alguma disposição destes Termos for considerada inválida ou inexequível, as restantes disposições mantêm-se em pleno vigor.</li>
          <li>A nossa falha em exercer qualquer direito previsto nestes Termos não constitui uma renúncia a esse direito.</li>
          <li>Estes Termos constituem o acordo integral entre si e a Gestão Mensal relativamente à utilização da App.</li>
        </ul>

        <h2 id="tu-16" className="text-xl font-bold mt-8 mb-3" style={{ color: "var(--text-primary)" }}>16. Contacto</h2>
        <p>Para questões sobre estes Termos de Utilização, contacte-nos:</p>
        <ul className="list-disc pl-6 space-y-1.5">
          <li><strong style={{ color: "var(--text-primary)" }}>Email:</strong> suporte@gestaomensal.app</li>
        </ul>
      </div>
    </LegalLayout>
  );
}
