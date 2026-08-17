## Dimensão: ux — a app faz sentido a quem a usa

Aqui julgas o **fluxo**, não o pixel. Percorre a app como alguém que a abre
pela primeira vez e quer fazer uma coisa concreta ("quanto gastei este mês?",
"registar o supermercado de hoje", "quanto falta para o meu objetivo?").

O que procurar:
- **feedback**: uma acção que grava sem confirmar nada; um erro que aparece sem
  dizer o que fazer; um botão que fica igual enquanto a app trabalha (o
  utilizador clica outra vez);
- **estados vazios**: um ecrã sem dados que não explica o que é nem o que
  fazer a seguir. Testa isto a limpar os dados de um ecrã, quando possível;
- **estados de carregamento**: spinners eternos, ou conteúdo que "salta"
  quando carrega;
- **estados de erro**: força um erro (ex: submeter um formulário vazio) e vê se
  a mensagem é útil e no idioma certo;
- **destinos sem saída**: um sub-ecrã de onde não se sai sem recarregar;
- **descoberta**: funcionalidade importante escondida atrás de três toques,
  ou um ícone sem rótulo cujo significado não se adivinha;
- **consistência de interacção**: a mesma acção feita de formas diferentes em
  ecrãs diferentes (num ecrã desliza-se, noutro há botão);
- **destrutivo sem confirmação**: apagar algo importante sem perguntar, ou sem
  permitir desfazer;
- **carga cognitiva**: números apresentados sem unidade nem período ("1.234"
  — de quê? deste mês?).

Cada finding deve dizer **que objetivo do utilizador é prejudicado** e não
apenas que algo é diferente do que esperavas. O critério é: alguém a usar isto
a sério fica bloqueado, confuso, ou perde dados?
