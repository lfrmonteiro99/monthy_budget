## Dimensão: layout — a app cabe no ecrã e alinha

Isto julga-se **a olhar para os screenshots**. Tira-os e usa `Read` neles.

Testa cada tab principal em **três viewports** e nos **dois esquemas de cor**:

```javascript
import { launch, close, openTab, shoot, layoutSuspects, VIEWPORTS } from './flutter_driver.mjs';
for (const [name, vp] of Object.entries(VIEWPORTS)) {
  for (const scheme of ['light', 'dark']) {
    const s = await launch({ url: '__APP_URL__', viewport: vp, colorScheme: scheme });
    for (const tab of ['home','track','shop','plan','more']) {
      await openTab(s.page, tab);
      await shoot(s.page, `__SCRATCH__/${name}-${scheme}-${tab}.png`);
      console.log(name, scheme, tab, JSON.stringify(await layoutSuspects(s.page)));
    }
    await close(s);
  }
}
```

`small` (360x640) é onde as coisas quebram primeiro — dá-lhe atenção especial.

O que procurar nas imagens:
- **texto cortado** ou com `…` onde havia espaço, ou a sair do cartão;
- **overflow horizontal**: conteúdo a passar a margem direita, barras de scroll
  horizontais onde não deviam existir;
- **sobreposições**: dois elementos a pintar um por cima do outro;
- **alinhamento**: itens de uma lista com margens diferentes entre si; números
  que deviam alinhar à direita e não alinham;
- **espaçamento inconsistente**: o mesmo tipo de cartão com respiros
  diferentes em ecrãs diferentes;
- **elementos escondidos atrás da navegação inferior** ou do teclado;
- **estado vazio mal composto** (ícone gigante, texto colado ao topo);
- **dark mode**: texto quase invisível, cartões sem contraste com o fundo,
  ícones que ficaram preto-sobre-preto.

Confirma cada `layoutSuspects` no screenshot antes de reportar — a caixa
semântica não é sempre exactamente a caixa pintada, e reportar sem confirmar
enche o backlog de falsos positivos.
