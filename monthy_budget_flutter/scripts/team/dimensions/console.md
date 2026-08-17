## Dimensão: console — o que a app grita quando ninguém ouve

Erros de runtime não aparecem sempre na UI: a app apanha excepções e mostra um
estado vazio, e o utilizador nunca sabe que algo falhou. Esta dimensão vai
buscá-los ao canal onde eles existem.

A app instala handlers globais em `lib/main.dart` (`FlutterError.onError` e
`PlatformDispatcher.instance.onError`) que registam tudo pelo `LogService` —
portanto o que passa pela consola do browser é sinal real da app, não ruído.

Percorre a app inteira **a fazer coisas** e recolhe no fim:

```javascript
import { launch, close, openTab, tap, scrollCollect } from './flutter_driver.mjs';
const s = await launch({ url: '__APP_URL__' });
for (const tab of ['home','track','shop','more']) {
  await openTab(s.page, tab);
  await scrollCollect(s.page, 8);
}
// abre modais, submete formulários, apaga coisas, volta atrás...
await s.page.reload(); await s.page.waitForTimeout(6000);
console.log('CONSOLE ERRORS:', JSON.stringify(s.logs.consoleErrors, null, 1));
console.log('PAGE ERRORS:',    JSON.stringify(s.logs.pageErrors, null, 1));
console.log('FAILED REQS:',    JSON.stringify(s.logs.failedRequests, null, 1));
await close(s);
```

O que reportar:
- **excepções não tratadas** (`pageErrors`): sempre defeito. Cita a mensagem e
  o que fizeste para a provocar.
- **erros de framework** do Flutter (assertion, `setState` após `dispose`,
  `RenderFlex overflowed`, "Looking up a deactivated widget's ancestor").
- **erros de parsing/tipo** (`type 'Null' is not a subtype of...`): indicam que
  o código assume um campo que pode não existir. Muito valioso: diz em que
  ecrã aconteceu.
- **pedidos falhados** que não sejam de serviços externos (fontes, analytics,
  supabase) — esses são esperados nesta máquina e já vêm filtrados.
- **erros que aparecem no arranque** e que ninguém vê porque a app mostra o
  ecrã por cima.

Para cada erro, esforça-te por dizer **qual a acção que o provoca**. Um stack
trace sem passos de reprodução é muito mais difícil de corrigir. Se um erro
aparece sempre, mesmo sem interacção, diz isso explicitamente.

Se não houver nenhum erro, `findings: []` — e diz em `coverage` que percorreste
tudo. É um resultado bom e útil.
