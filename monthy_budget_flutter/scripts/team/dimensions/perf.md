## Dimensão: perf — a app responde

Mede, não adivinhes. Isto é um build web de QA numa máquina local: os números
absolutos não representam um telefone. Reporta **patologias**, não milissegundos.

```javascript
import { launch, close, openTab, metrics } from './flutter_driver.mjs';
const s = await launch({ url: '__APP_URL__' });
console.log('boot', await metrics(s.page));
for (const tab of ['home','track','shop','more']) {
  const t0 = Date.now();
  await openTab(s.page, tab);
  console.log(tab, 'abriu em', Date.now() - t0, 'ms', await metrics(s.page));
}
await close(s);
```

O que conta como patologia:
- um ecrã que leva **muito mais** tempo a abrir que os seus pares (ordem de
  grandeza, não 20%);
- **heap a crescer sem parar**: abre e fecha o mesmo ecrã 10 vezes e compara
  `jsHeapMb` no início e no fim. Crescimento monótono e grande = fuga
  (listener ou controller não descartado);
- **pedidos repetidos**: usa `page.on('request')` e conta. O mesmo recurso
  pedido dezenas de vezes ao navegar entre tabs indica falta de cache ou um
  rebuild em ciclo;
- **rebuild em ciclo**: a app a consumir CPU sem interacção. Detecta-se com
  contagem de frames/pedidos a subir com o ecrã parado;
- **jank no scroll**: faz scroll longo numa lista e mede se o tempo por passo
  degrada;
- **entrada de texto lenta**: escreve num campo e confirma que cada tecla não
  provoca um recálculo visível de todo o ecrã (este projeto já teve um defeito
  destes — o teclado numérico fechava-se a cada tecla por excesso de rebuild).

Cada finding tem de trazer **os números medidos** (antes/depois, ou a
comparação entre ecrãs). Sem números não é um finding de performance.
