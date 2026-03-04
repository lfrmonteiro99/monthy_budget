# Checklist de Validação no Telemóvel (APK)

## Pré-requisitos

- App instalada com o build mais recente.
- Internet ativa no telemóvel.
- Projeto Supabase com função `openai-chat` deployada.
- Secret configurado no Supabase:
  - `OPENAI_API_KEY`

## 1) Verificação rápida de IA (sem API key local)

1. Abrir `Settings > AI Coach`.
2. Confirmar que aparece mensagem de key protegida no servidor (não pede `sk-...`).
3. Ir ao separador `Coach`.
4. Carregar em `Analyze my budget`.
5. Resultado esperado:
   - análise gerada com sucesso;
   - histórico atualizado.

## 2) Meal Planner AI

1. Abrir `Refeições`.
2. Gerar plano (se ainda não existir).
3. Abrir uma refeição e validar que aparecem conteúdos AI (steps/tip/variação).
4. Ir para semana com receitas batch e carregar em `Batch prep guide`.
5. Resultado esperado:
   - guia de batch cooking abre sem pedir API key local.

## 3) Bill reminders

1. Em `Settings > Notifications`, ativar `Bill reminders`.
2. Definir `days before` para 1.
3. Em contas recorrentes, configurar uma conta com vencimento para amanhã.
4. Fechar app e aguardar.
5. Resultado esperado:
   - notificação local recebida antes do vencimento.

## 4) Budget alerts (threshold)

1. Em `Settings > Notifications`, ativar `Budget alerts`.
2. Definir threshold (ex.: 80%).
3. Registar despesas até ultrapassar o limite global ou de categoria.
4. Resultado esperado:
   - receber alerta de orçamento.

## 5) Subscrições (RevenueCat real)

1. Abrir paywall.
2. Tentar compra real (sandbox/test account).
3. Resultado esperado:
   - se offerings/produtos estiverem corretos, fluxo de compra abre loja.
   - se não houver package configurado, aparece erro explícito (`No store package available...`).

## 6) Cenários de erro esperados

- Sem `OPENAI_API_KEY` no Supabase:
  - Coach/Meal AI devem falhar com erro de servidor, sem crash.
- Função `openai-chat` não deployada:
  - chamadas AI falham com erro de function not found.

## 7) Comandos úteis (ambiente dev)

```bash
supabase secrets set OPENAI_API_KEY=sk-... --project-ref YOUR_PROJECT_REF
supabase functions deploy openai-chat --project-ref YOUR_PROJECT_REF
```
