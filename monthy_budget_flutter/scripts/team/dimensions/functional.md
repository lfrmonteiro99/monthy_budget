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

## Propagação: o efeito chega a TODOS os sítios que dependem dele

Esta é a parte mais valiosa desta dimensão, e a mais fácil de deixar passar.
Uma acção num ecrã tem de se refletir em **todos** os outros que dependem dela —
e **só** nesses. Um total que actualiza no dashboard mas não nas tendências é um
defeito tão real como um botão que não faz nada, e muito mais difícil de notar.

Método: faz **uma** alteração com um valor reconhecível (ex: `77,77 €`, uma
categoria que ainda não tenha despesas), e depois percorre **todos** os ecrãs
dependentes a verificar onde apareceu e onde não apareceu. Anota o valor antes e
depois em cada sítio.

Matriz de propagação a verificar (adapta ao que a app tiver):

| Acção | Tem de mudar | Não deve mudar |
|---|---|---|
| Adicionar despesa numa categoria | total do mês; "gasto" na liquidez; % e barra dessa categoria em Top Categorias; velocidade de gasto / média-dia; previsão de fim do mês; taxa de poupança; lista de recentes e a contagem de transações; tendências e orçamento-vs-real | totais de **outros** meses; orçamentos definidos; outras categorias |
| Editar o valor de uma despesa | tudo o que a linha acima afecta, pela **diferença** | a contagem de transações |
| Apagar uma despesa | tudo o que a linha acima afecta, em sentido inverso | — |
| Alterar o orçamento de uma categoria | restante e % dessa categoria; alertas de "acima do orçamento"; orçamento-vs-real | o valor **gasto**; outras categorias |
| Adicionar despesa recorrente | aplicação ao mês corrente; previsão/contas pendentes; totais | meses já passados |
| Contribuir para um objetivo | progresso e % do objetivo; projeção de conclusão; poupança do mês | outros objetivos |
| Marcar item da lista de compras | progresso da lista; contagem de itens em falta | despesas (só ao registar a compra) |
| Alterar dados pessoais nas definições | entradas do simulador fiscal; rendimento líquido; descontos | despesas registadas |

Dois tipos de defeito, ambos a reportar:

1. **Não propagou** — o valor mudou num ecrã e ficou desactualizado noutro que
   depende dele. Diz **onde actualizou** e **onde não**; é isso que localiza a
   causa (normalmente falta de invalidação de cache ou um estado não notificado).
2. **Propagou onde não devia** — a acção mexeu em algo que não lhe compete
   (outro mês, outra categoria, outro objetivo). Isto é pior que o primeiro:
   corrompe dados em silêncio.

Verifica também a propagação **após reload**: um valor que aparece só em memória
e não sobrevive ao reload propagou para a UI mas não para o sqlite.
