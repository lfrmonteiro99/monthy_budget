## Dimensão: design — coerência com o sistema "Calm"

Esta app tem um sistema de design documentado. **Lê-o primeiro** (no repositório
em `__REPO_PKG__`):

- `docs/calm-handoff.md` — tokens (§2), tipografia (§3), padrões de layout (§4)
  e a checklist de coerência (§7).

Depois compara o que está **nos screenshots** com o que o documento manda.

O que procurar:
- **tipografia**: tamanhos/pesos fora da escala definida; o número herói de um
  ecrã com um tipo de letra diferente do de outro ecrã equivalente;
- **cor**: cores fora da paleta de tokens; a mesma semântica (positivo,
  negativo, aviso) pintada de cores diferentes em ecrãs diferentes;
- **cartões**: raios de canto, sombras, bordas e preenchimento inconsistentes
  entre ecrãs;
- **ícones**: estilos misturados (preenchido vs contorno) no mesmo ecrã, ou
  tamanhos desalinhados;
- **hierarquia**: o elemento mais importante do ecrã não é o mais destacado;
  dois elementos a competir pela mesma atenção;
- **densidade**: um ecrã visivelmente mais apertado ou mais vazio que os seus
  pares, sem razão;
- **estados**: botões primários/secundários/desactivados sem tratamento
  distinto e consistente.

Compara **ecrãs entre si**: a incoerência é o defeito mais comum e só se vê
lado a lado. Tira os screenshots de todas as tabs e olha para eles em sequência.

Um finding aqui deve citar a regra concreta que está a ser violada (o token, o
tamanho, o padrão do handoff) e qual o ecrã que a cumpre — para o implementador
saber para onde convergir. "Não parece Calm" não é acionável.
