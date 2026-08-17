## Dimensão: data — os números estão certos

A app é sobre dinheiro. Um número errado é o defeito mais grave que pode ter, e
é o único tipo que a UI nunca denuncia: parece perfeito e está mal.

Método: **calcula tu à parte e compara**. Lê os itens que a app lista, soma-os
com o teu próprio cálculo, e confronta com o total que ela mostra. Quando
divergem, o finding traz os dois números e a conta.

O que verificar:

1. **Somas e totais** — o total do mês bate com a soma das despesas listadas?
   Inclui as recorrentes? O "restante" é `orçamento − gasto`? As percentagens
   de categoria somam 100%?
2. **Arredondamento de moeda** — dois decimais, sempre. Procura `12.3`,
   `12.345`, ou um total que difere em cêntimos da soma das partes (sinal de
   arredondar antes de somar em vez de somar antes de arredondar).
3. **Fronteiras de mês** — uma despesa no dia 1 e outra no último dia do mês
   caem no mês certo? O mês anterior/seguinte mostra os dados correctos ao
   navegar? Confirma que os dados semeados de meses anteriores aparecem no mês
   a que pertencem.
4. **Objetivos de poupança** — o progresso é `contribuições / objetivo`? A
   projeção de conclusão é coerente com o ritmo? Um objetivo concluído mostra
   100% e não mais?
5. **Simulador fiscal (IRS português)** — a área de maior risco. Verifica com
   valores concretos: escalões e taxas aplicados progressivamente (não a taxa
   do escalão sobre o rendimento todo); mínimo de existência; dedução
   específica; sobretaxa; dependentes; estado civil; subsídios de férias e
   Natal tributados como devem. Compara com o que a lei manda para o ano que a
   app diz estar a usar. Se a app não indica o ano das tabelas, **isso é um
   finding**: uma tabela fiscal sem ano é impossível de validar.
6. **Divisão por zero e vazios** — um orçamento a zero, uma categoria sem
   despesas, um objetivo sem contribuições: mostra `0`, `—`, ou `NaN`/`Infinity`?
   `NaN` no ecrã é sempre defeito.
7. **Sinais** — despesas e receitas com o sinal certo; um saldo negativo
   apresentado como negativo e não em valor absoluto.
8. **Valores extremos** — introduz `0`, `0,01`, um valor muito grande
   (`999999,99`) e um negativo. A app deve tratá-los ou rejeitá-los, nunca
   mostrar lixo.

Podes ler o código para confirmar a fórmula (`lib/services/`, `lib/utils/`),
mas o finding tem de nascer de um **valor errado observado na app**, com os
passos para o reproduzir. Uma fórmula que te parece suspeita mas produz o
resultado certo não é um defeito.
