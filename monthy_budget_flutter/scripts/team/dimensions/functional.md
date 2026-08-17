## Dimensão: functional — as funcionalidades fazem o que prometem

Testa **comportamento**, com o CRUD completo e a persistência. Um ecrã que
mostra dados mas não os grava é um defeito funcional, não de layout.

Para cada fluxo: executa-o, confirma o efeito no ecrã, **recarrega a página**
(`page.reload()` + `waitForApp` + `enableSemantics`) e confirma que o efeito
sobreviveu. A app grava em sqlite local, portanto tem de sobreviver.

Fluxos a cobrir (aprofunda os que a app oferece; ignora os que não existem):

1. **Despesas** — adicionar uma despesa (valor, categoria, data, descrição);
   confirmar que aparece na lista e que os totais do mês mudam de acordo;
   editar; apagar. Um valor decimal (ex: `12,34`) tem de ser aceite e mostrado
   com o mesmo valor.
2. **Orçamento** — definir/alterar o orçamento de uma categoria; confirmar que
   o restante e a percentagem recalculam.
3. **Despesas recorrentes** — criar uma; verificar se aparece e se é aplicada
   ao mês.
4. **Objetivos de poupança** — criar objetivo; adicionar contribuição;
   confirmar progresso; concluir/pausar.
5. **Lista de compras** — adicionar item, marcar/desmarcar, remover, limpar
   marcados. Verificar que a lista é *stream-driven*: a UI actualiza sem
   navegar fora e voltar.
6. **Planeamento de refeições** — gerar/abrir plano, trocar uma refeição,
   enviar ingredientes para a lista de compras.
7. **Definições** — alterar uma definição (tema, moeda, idioma, dados
   pessoais); confirmar que aplica e que persiste após reload.
8. **Navegação** — todas as tabs abrem; o botão de voltar/fechar sai de
   modais e sub-ecrãs sem deixar a app presa.

Sinais de defeito funcional:
- uma acção não tem efeito visível nenhum (nem sucesso nem erro);
- o efeito desaparece após reload (não persistiu);
- os totais não batem com os itens listados;
- um formulário aceita valores inválidos (negativos, vazios, texto num campo
  numérico) sem os rejeitar nem avisar;
- um botão não faz nada, ou faz duas vezes a mesma coisa;
- a app fica presa num spinner.
