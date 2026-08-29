# Pipeline autónomo de QA

Uma equipa de agentes que testa a app a correr num browser, abre issues do que
está mal, analisa-os, corrige-os, revê as correções e volta a testá-las antes de
fechar. Vive em `scripts/team/`.

## Os papéis

| Papel | Script | O que faz | Testa que branch |
|---|---|---|---|
| **Critic** | `critic.sh` | Conduz a app num browser e abre issues do que encontra | `main` |
| **Curator** | `curator.sh` | Investiga a causa raiz e escreve o briefing (causa, plano, critérios de aceitação, como testar) | — |
| **Implementador** | `implement.sh` | Corrige em `qa/issue-N` e abre PR para `dev` | — |
| **Reviewer** | `review.sh` | Lê o diff, corre os testes, aprova ou devolve | — |
| **Gate pré-merge** | `premerge.sh` | Testa a app compilada do branch do PR e **só então** integra | `qa/issue-N` |
| **QA Verifier** | `verify.sh` | Volta a testar o fix já integrado e fecha o issue | `dev` |
| **Promoção** | `promote.sh` | Leva `dev` para `main` em lote: fim da janela de quota, 6 fixes, ou fila vazia | — |
| **Orquestrador** | `orchestrator.sh` | Despacha tudo pela máquina de estados | — |

## Topologia de branches

```
main ──────────────────────────────►  produção. O CRITIC testa aqui.
  │                            ▲
  └──► dev ───────────────────┘       staging de QA. O VERIFIER testa aqui.
         ▲                            Promovido em lote (ver Promoção).
         └── qa/issue-N               branches do implementador. PR ──► dev.
                                      O GATE PRÉ-MERGE testa aqui, antes do merge.
```

Três branches, três testes no browser, e nenhum deles é opcional: o critic
pergunta "o que está mal na produção", o gate pré-merge pergunta "isto resolve
mesmo, antes de entrar", e o verifier pergunta "continua a resolver depois de
integrado ao lado dos outros fixes".

O critic testa `main` de propósito: interessa saber o que está mal na app tal
como está publicada. O verifier testa `dev` porque é lá que o fix está.

## Máquina de estados

O estado de um issue é **exactamente uma** label `qa:*`. Os comentários são o
registo de auditoria; a label é o que o orquestrador despacha.

```
qa:triage ──curator──► qa:ready ──implementador──► qa:review ──reviewer──┐
    ▲                     ▲                            │                │
    │                     │                     blocked-impl        approved
    │                     │                            │         (NÃO integra)
    │              qa:blocked-impl ◄────────────────────┤                │
    │                     ▲                             │                ▼
    │                     │                             │          qa:premerge
    │                     │                             │   gate no browser sobre
    │                     │                             │   o branch do PR
    │                     │                  fail-impl  │                │
    │                     │                             ├────────────────┤
    │                     │                                        pass  │
    │                     │                                    (merge ──►dev)
    │                     │                                              ▼
    │                     │                                         qa:verify
    │                     │  fail-impl                                   │
    │                     └───────────────────────────────────────────────┤
    │                                                                    │
qa:blocked-spec ◄──── blocked-spec / fail-spec ──────────────────────────┤
                                                                   pass  │
                                                                         ▼
                                                                     qa:done
                                                                    (fechado)
```

### Porque o merge acontece depois do teste, e não antes

O reviewer lê o diff e corre a suite. Nenhuma das duas coisas mostra que a **app**
funciona; só conduzir a UI mostra. Esse teste já existia, mas corria *depois* do
merge — e a pipeline não tem revert. Quando o verifier reprovava, o commit partido
**ficava em `dev`** e o issue voltava a `qa:blocked-impl`.

Pior: `maybe_promote` só adia a promoção por issues em `qa:verify`. Um fix já
provado partido está em `qa:blocked-impl`, que não bloqueia nada — portanto podia
ser promovido para `main` enquanto a re-correção ainda estava na fila.

Testar antes do merge fecha os dois por construção: nada chega a `dev` sem ter sido
conduzido num browser. O `qa:verify` mantém-se porque responde a outra pergunta —
não "isto resolve?", mas "continua a resolver depois de integrado?".

Uma corrida do gate que não produz veredicto **não** faz merge: o issue volta a
`qa:premerge` e o PR fica aberto. Silêncio não é consentimento.

**Não existe `qa:needs-human`.** Não há ninguém do outro lado, por isso "escalar para
humano" nunca foi uma resolução — era uma forma de perder trabalho em silêncio (cinco
issues ficaram parados assim, dois deles já implementados e com o código enviado).
Cada saída tem destino produtivo: uma corrida sem veredicto devolve o issue à fila
(falha da *corrida*, não do issue), um briefing que não leva a lado nenhum vai para
`qa:blocked-spec`, e um pai de split é **fechado** — o trabalho vive nos sub-issues.

Quando um issue encrava, escala a **estratégia**, não o issue:

| Tentativa | O que acontece |
|---|---|
| 1-2 | implementa normalmente |
| 3 | volta ao curator **com o histórico de falhas** — o briefing é reescrito a partir do que falhou, não do palpite inicial |
| 4+ | força `split` em pedaços que caibam |

### Quantos issues correm ao mesmo tempo

Os papéis de escrita partilhavam um lock, pela razão no cabeçalho do
`orchestrator.sh`: dois agentes a fazer push ao mesmo tempo é como se perde trabalho.
Verdade para o **mesmo** issue, falso para issues diferentes — cada implementador tem
a sua worktree e o seu branch `qa/issue-N`.

Correm agora até `TEAM_MAX_PARALLEL` em simultâneo, com omissão derivada da memória
**disponível** (não dos cores, não da RAM total): um `flutter build web --release`
tem picos de 2-3 GB, e duas dessas numa máquina que entra em swap são mais lentas do
que uma que não entra. O tecto rígido (`TEAM_MAX_PARALLEL_CEILING`, 4) não é sobre a
máquina: o recurso escasso é a quota da subscrição, e N agentes gastam-na N vezes
mais depressa.

O que a frota tem de coordenar, e onde estava o risco:

| Recurso | Porque colide | Como se resolve |
|---|---|---|
| lock do agente | `run-agent.sh` aborta com `exit 75` se o slot estiver tomado | um slot por despacho (`main-1`…`main-N`) |
| porta do gate | o `serve-app.sh` liberta a porta de quem a segurar, portanto o gate B mata o servidor do A **e o tester de A passa a conduzir o build de B** — veredicto sobre o branch errado | porta por slot (`7403 + índice`) |
| o issue | `qa:premerge` e `qa:verify` não mudam de etiqueta durante a corrida | registo de issues em voo (`first_unclaimed`) |
| veredictos | o `cleanup_stale` apaga ficheiros de veredicto; com um slot, ter o lock provava que nada corria — com N não prova nada | só apaga com a frota toda parada |

O curator fica **fora** da frota: tem um lock próprio e uma segunda instância abortaria
com `exit 75`. Continua a correr em paralelo no seu slot, e serve as duas filas
(`qa:blocked-spec` antes de `qa:triage` — um briefing errado à espera é um
implementador a construir contra ele outra vez).

A promoção é adiada enquanto houver qualquer slot ocupado: o `promote.sh` assume que
nada está a meio, e um gate a integrar durante a promoção põe um fix por verificar
em `main` entre duas leituras.

Com `TEAM_MAX_PARALLEL=1` o comportamento é indistinguível do anterior.

### O travão das corridas sem veredicto

Três estados devolvem o issue a si próprios quando a corrida não produz veredicto:
`qa:ready` (implementador), `qa:premerge` e `qa:verify` (os dois testers). É o
instinto certo — é falha da *corrida*, não do issue.

Mas nenhum desses despachos incrementa contador (o `escalate_if_stuck` só dispara
no caminho de `qa:blocked-impl`), portanto o requeue não tinha chão:

```
qa:ready -> implementador -> 45 min de timeout -> sem veredicto -> qa:ready -> ...
```

Medido no #1307: `rc=124` ao fim dos 2700s, motor saudável, os dois cooldowns de
quota no passado, e o contador de tentativas ainda a marcar 1 no fim.

Um **timeout** é diferente em espécie das outras maneiras de não produzir veredicto.
Um agente que rebenta não disse nada sobre o issue; um agente que gastou o relógio
inteiro disse: o trabalho não cabe numa corrida. Dois seguidos vão para
`qa:blocked-spec` — é o curator que reescreve mais pequeno ou parte.

| Como a corrida acabou | Efeito no contador |
|---|---|
| timeout (`rc=124`) | +1; ao 2.º, escala para `qa:blocked-spec` |
| erro do agente | reinicia — não diz nada sobre o tamanho do issue |
| degradada (sem quota, `exit 75`) | intocado — o motor nem chegou a tentar |
| veredicto escrito | limpo |

Validado no #1202: falhou 3 vezes a reservar espaço para o FAB dentro do ecrã
interior; a reanálise identificou que o FAB vive no `Scaffold` exterior, e a
abordagem seguinte (widget `FabClearance` no mesmo Scaffold) passou à primeira.

### Porque há dois tipos de bloqueio

`blocked-impl` (problema de código) volta ao implementador; `blocked-spec`
(briefing errado) volta ao curator. Sem esta distinção, um issue cujos critérios
de aceitação estão errados entra em ciclo infinito: o implementador cumpre o
contrato, o QA reprova, e ele volta a implementar exactamente a mesma coisa
errada. Se a instrução estava mal, o que tem de mudar é a instrução.

## QA mode: como é que os testers entram na app

A app está fechada por autenticação Supabase (`lib/screens/auth/auth_gate.dart`).
Sem credenciais — e não há, nem se usa a base de dados de produção para testes —
um tester só conseguiria ver o ecrã de login.

`--dart-define=QA_MODE=true` resolve isso:

- `lib/config/qa_mode.dart` — a flag (`bool.fromEnvironment`, portanto o código
  de QA é removido pelo tree-shaking num build normal);
- `lib/repositories/repository_factory.dart` — o ponto único onde os serviços
  resolvem os seus repositórios. Por omissão devolve os `Supabase*`;
- `lib/repositories/qa/` — implementações contra **sqlite local**
  (`lib/repositories/local/qa_local_store.dart`, uma tabela de documentos JSON
  via SQL cru no drift, sem codegen);
- dados semeados de forma determinística, para os testers julgarem números e
  estados contra algo estável;
- o gate de autenticação é contornado e a app arranca directamente na shell.

Em web o drift usa `WasmDatabase`, e por isso `web/sqlite3.wasm` e
`web/drift_worker.js` são obrigatórios no repositório.

**O comportamento de produção não muda:** com a flag desligada, o caminho é o
Supabase de sempre.

## O toolkit de browser

`scripts/team/qa/flutter_driver.mjs` e `probe.mjs`. Correm de
`~/Documentos/monthy-budget-qa-tools` (projecto npm próprio, com o playwright).

A app compila com o renderer CanvasKit: **pinta num canvas**. Não há nós de texto
no DOM, nem cores em CSS, nem caixas de elementos para inspeccionar. Sobram duas
fontes de verdade, e o toolkit expõe as duas:

1. **A árvore semântica** — o Flutter espelha os widgets em `<flt-semantics>` com
   `aria-label`, `role` e caixa real. É a visão estrutural: o que existe, como se
   chama, onde está, se é alcançável. Tudo o que é programático sai daqui.
2. **Screenshots** — a única forma de julgar aparência. O agente lê o PNG e
   forma um juízo visual, como um revisor humano.

A árvore semântica só existe depois de activar a acessibilidade
(`enableSemantics()`). Esquecer isso é a razão nº1 para um probe "não encontrar
nada".

## TDD, com o passo vermelho provado

O implementador escreve o teste **primeiro** e tem de o ver falhar **pela razão
certa** antes de tocar no código de produção, registando a mensagem de falha no corpo
do PR. Não é cerimónia: um reviewer deste pipeline já refutou empiricamente um teste
escrito depois do fix — reverteu o ficheiro de produção, o teste continuou a passar, e
ficou provado que não testava nada.

O reviewer **verifica** essa prova em vez de a aceitar (`red_step_proven`,
`edge_cases_covered` são campos do veredicto), e revert-e-corre ele próprio se a
alegação parecer fraca.

Testes do caminho feliz não chegam. Exige-se, conforme aplicável: fronteiras (0, 1, o
limite ±1 — fix a 360px testa 359 e 361), vazios e `null`, entradas inválidas,
**repetição** (este projeto já gravou uma despesa duas vezes), e o inverso do fix. Um
teste que não pode falhar é pior que nenhum: compra confiança falsa.

## Conflitos de merge

Um PR aprovado que não integra **não é código mau**. O `implement.sh` integra o `dev`
e, havendo conflito, deixa os marcadores na árvore e entrega-os ao agente para
resolver **por intenção** — perceber o que cada lado queria e preservar ambos. Nunca
`--ours`/`--theirs` em bloco (apaga trabalho alheio em silêncio); em ARB e ficheiros
gerados, manter as chaves dos dois lados e regenerar.

## Dimensões de teste

Uma por ficheiro em `scripts/team/dimensions/`, corridas **em paralelo** (só leem
a app, não podem conflituar). O arquivamento dos findings é depois **serializado**
e desduplicado, para dois testers que viram o mesmo defeito não abrirem dois
issues.

`functional` · `layout` · `design` · `ux` · `a11y` · `i18n` · `perf` · `console` · `data`

Acrescentar uma dimensão é acrescentar um ficheiro `.md` e o nome à lista em
`critic.sh`.

## Visão: o pedido é dividido

Vários papéis precisam de **ver** os screenshots. O Claude vê; o modelo de fallback
não aceita imagens de todo, e falha com violência — `400 this model does not support
image input` mata a corrida inteira sem veredicto.

A solução não é cegar o agente, é **dividir o pedido**: `qa-describe-image.sh` manda o
screenshot a um modelo de visão (`gemma4:31b`, escolhido por teste contra um
screenshot real — o `glm-5.2` e o próprio `deepseek-v4-flash` não têm visão) e devolve
a descrição em texto, que o modelo de raciocínio usa como qualquer outra prova.

Detalhes que só aparecem a construir: o payload vai por **ficheiro** (um screenshot em
base64 são ~140KB e o `curl -d` morre com *argument list too long*), e o prompt exige
**perguntas fechadas** — "o valor do cartão 'Este Mês' está truncado?" em vez de
"descreve a imagem". O agente é instruído a citar a descrição como prova de segunda
mão, para os veredictos não fingirem uma observação que não fizeram.

## Motor: subscrição com fallback

`run-agent.sh` corre o harness do Claude Code. Primeiro na subscrição local
(`claude -p`); quando o usage acaba, o mesmo harness passa a correr contra um
modelo Ollama Cloud (`ollama launch claude`). As ferramentas do agente são as
mesmas nos dois casos — só muda o modelo.

Distingue "sem quota" de "o agente falhou a tarefa": só o primeiro justifica o
fallback, e é registado um cooldown para não se gastar um pedido condenado por
ciclo.

## Correr

```bash
cd monthy_budget_flutter

# um ciclo, sem abrir nada novo (bom para inspeccionar)
bash scripts/team/orchestrator.sh --once --no-critic

# dois loops completos e para
bash scripts/team/orchestrator.sh --loops 2

# só o critic, uma dimensão
bash scripts/team/critic.sh --dimensions layout

# um issue ou um PR específico
bash scripts/team/orchestrator.sh --issue 1200
bash scripts/team/orchestrator.sh --pr 1201

# servir a app à mão
bash scripts/team/serve-app.sh main      # :7401
bash scripts/team/serve-app.sh dev       # :7402
bash scripts/team/serve-app.sh dev --status
```

Um **loop** = o backlog chegar a zero. Aí promove-se `dev` e o critic corre outra
vez.

### Estado fora do repositório

Veredictos, worktrees e estado do orquestrador vivem **fora** da árvore de
trabalho, em `~/Documentos/monthy-budget-verdicts/` e
`~/Documentos/monthy-budget-wt/`. Dentro do repositório causavam três avarias ao
mesmo tempo: ficavam versionados, uma corrida que morria antes de escrever
herdava o veredicto da anterior (e reportava o trabalho de outro issue como
seu), e o `git add -A` arrastava-os para o diff do PR.

Logs em `/tmp/monthy-budget-team/`.

## Interacção com o CI

Foi preciso mexer nos workflows — o que já existia atropelava este desenho.

| Workflow | Mudança | Porquê |
|---|---|---|
| `agent-delivery.yml` | ignora `dev` e `qa/**` | Abria PR para `main` e fazia auto-merge. Nos branches do pipeline, o código entrava em produção **antes** de o reviewer correr: reviewer, verifier e o staging em `dev` ficavam decorativos. |
| `pr-test.yml` | **novo** | `main` exige o check `test`. Ele vinha por acidente do `agent-delivery` (job em `push`). Ao deixar de disparar em `dev`, o PR de promoção nunca receberia `test` e ficaria preso para sempre. Agora é produzido no evento `pull_request`. |
| `quality-gates.yml` | + `dev` nos PRs | Sem isto o reviewer decidiria sem cobertura, validação de ARB nem scan de segredos. |
| `flutter-ci.yml` | + `dev` nos PRs | Coerência. |
| `pr-governance.yml` | label de release só obrigatória para `main` | A label alimenta o CalVer do `release-tag.yml`. PRs para `dev` não publicam nada, e exigi-la reprovava todos eles por um valor que ninguém lê. O link para o issue continua obrigatório em todos. |

`release-tag.yml`, `supabase-price-sync.yml` e `scrape-grocery-prices.yml` só
correm em `main` e não foram alterados: são o caminho de produção e é o PR de
promoção que os deve accionar.

## Extender

- **Nova dimensão de teste** → um `.md` em `dimensions/` + nome na lista de
  `critic.sh`.
- **Mudar critérios de um papel** → o `*-prompt.md` correspondente. Os prompts
  são o contrato; os `.sh` só transportam estado.
- **Novo papel** → um `.sh` que escreve veredicto em `$VERDICT_DIR`, um
  `*-prompt.md`, e um ramo no despacho do `orchestrator.sh`.

## Limitações honestas

- **A app é mobile; o teste é web.** Biometria, câmara, scanner, notificações
  push e compras in-app não funcionam no browser *por construção* e estão
  explicitamente fora do âmbito dos testers. Defeitos exclusivos de Android/iOS
  passam por aqui sem serem vistos.
- **Overflow de layout não vem da consola.** Os builds são `--release`, onde as
  asserções do Flutter (incluindo `RenderFlex overflowed`) estão desligadas. A
  detecção é por caixas semânticas fora da viewport (heurística) e por inspecção
  visual dos screenshots.
- **Os dados são semeados, não reais.** Um defeito que só aparece com dados de
  produção reais não é encontrado aqui.
- **A desduplicação é mecânica** (sobreposição de tokens no título). Erra por
  excesso de arquivamento: é o curator que fecha duplicados, porque um duplicado
  é barato e um defeito real silenciosamente descartado é invisível para sempre.
- **`sev:` e `confidence` são juízo de um modelo**, não medições.
