# Template de relatório científico (LuaLaTeX)

Template em LuaLaTeX que reproduz a formatação do arquivo `Relatoriomassa.doc`:
papel A4, margens de 25 mm, duas colunas, texto em Times New Roman 12 pt,
título em Arial 14 pt negrito, legendas e tabelas em 10 pt, seções numeradas,
citações no formato autor–ano e referências em ordem alfabética.

A montagem do documento é automatizada por um módulo em Lua: título, autores,
resumo, tabelas (a partir de CSV), figuras, citações e lista de referências são
gerados a partir de arquivos de configuração, sem escrever LaTeX repetitivo.

## Requisitos

- TeX Live 2021 ou superior (ou MiKTeX atualizado) com:
  - `lualatex` e `latexmk`;
  - pacotes `fontspec`, `unicode-math`, `geometry`, `babel`, `microtype`,
    `graphicx`, `xcolor`, `array`, `tabularx`, `float`, `cuted`, `caption`,
    `titlesec`, `fancyhdr`, `indentfirst`, `enumitem`, `hyperref`.
- Fontes Times New Roman e Arial (Microsoft). Caso não estejam instaladas, o
  template usa automaticamente as equivalentes livres **Liberation Serif** e
  **Liberation Sans**, metricamente compatíveis.
- Fonte matemática `TeX Gyre Termes Math` (pacote `tex-gyre-math`, presente no
  TeX Live completo).

Os padrões de hifenização do português já estão incluídos em
`scripts/hyph-pt.tex` (licença BSD-3-Clause), portanto não é necessário
instalar o pacote `hyphen-portuguese` do sistema.

> O template **exige LuaLaTeX**. Não compile com pdfLaTeX: as automações
> dependem do interpretador Lua embutido.

## Compilação

No diretório do projeto:

```bash
latexmk -lualatex main.tex
```

O PDF gerado é `main.pdf`. Para uma compilação limpa:

```bash
latexmk -C && latexmk -lualatex main.tex
```

Também há um `Makefile`:

```bash
make          # compila main.pdf
make clean    # remove arquivos auxiliares
make distclean # remove também o PDF
```

O arquivo `.latexmkrc` já fixa o modo LuaLaTeX, então `latexmk main.tex` também
funciona. O `main.tex` começa com `% !TEX program = lualatex`, diretiva
reconhecida por editores como TeXstudio, VS Code (LaTeX Workshop) e TeXShop.
Se o arquivo for compilado com pdfLaTeX por engano, o template interrompe com
uma mensagem explícita em vez do erro genérico do `fontspec`.

## Estrutura do projeto

```
.
├── main.tex                  # conteúdo do relatório
├── relatorio.cls             # classe com a formatação e a interface Lua
├── scripts/
│   ├── relatorio.lua         # automações (CSV, tabelas, figuras, citações)
│   └── hyph-pt.tex           # padrões de hifenização do português
├── config/
│   ├── relatorio.lua         # título, autores, matrículas e resumo
│   ├── tabelas.lua           # definição das tabelas
│   ├── figuras.lua           # definição das figuras
│   └── referencias.lua       # base de referências
├── dados/
│   ├── tabela1.csv           # dados da Tabela 1
│   └── tabela2.csv           # dados da Tabela 2 (com incertezas)
├── figuras/
│   ├── figura1.png
│   └── figura2.png
├── Makefile
├── .latexmkrc
└── .gitignore
```

## Como usar

### Título, autores e resumo

Edite apenas `config/relatorio.lua`:

```lua
return {
  titulo = "Escreva aqui o título do relatório",
  autores = {
    { nome = "Nome Completo", matricula = "2026000000" },
  },
  resumo = [[Texto do resumo...]],
}
```

O título é convertido para maiúsculas automaticamente e cada autor é impresso
como `Nome -- matrícula 000000`.

### Tabelas

1. Coloque os dados em um CSV em `dados/`. A primeira linha contém os nomes das
   colunas; o separador pode ser vírgula ou ponto e vírgula.
2. Declare a tabela em `config/tabelas.lua`:

```lua
tabela3 = {
  arquivo = "dados/tabela3.csv",
  legenda = "Resultados do experimento",
  rotulo = "tab:resultados",
  fonte = "Autoria deste trabalho",
  largura = "\\columnwidth",
  posicao = "H",
  colunas = {
    { titulo = "Ensaio", campo = "ensaio", formato = "texto" },
    { titulo = "Massa (g)", campo = "massa", formato = "decimal" },
    { titulo = "Tempo (s)", campo = "tempo", campos = { "tempo", "tempo_erro" }, formato = "mais_menos" },
  },
}
```

3. No texto, use `\tabela{tabela3}` e cite com `Tabela~\ref{tab:resultados}`.

Formatos numéricos disponíveis:

| Formato      | Efeito                                      |
|--------------|---------------------------------------------|
| `texto`      | valor literal do CSV                        |
| `milhar`     | `5641` → `5.641`                            |
| `decimal`    | `9.1` → `9,1`                               |
| `mais_menos` | dois campos → `9,1 ± 0,2` (em modo matemático) |

Campos opcionais: `pesos` (proporção das colunas), `espacamento_linhas`
(padrão `1.6`), `larga` (tabela de página inteira) e `largura`.

### Figuras

Coloque a imagem em `figuras/` e declare em `config/figuras.lua`:

```lua
figura3 = {
  arquivo = "figuras/figura3.png",
  legenda = "Montagem experimental.",
  rotulo = "fig:montagem",
  largura = "0.9\\columnwidth",
  posicao = "H",
}
```

No texto: `\figura{figura3}` e `Figura~\ref{fig:montagem}`.

### Tabelas e figuras de página inteira

Quando a tabela ou figura não couber em uma coluna, use `larga = true` e
`largura = "\\textwidth"`. No `main.tex`, coloque os elementos dentro do
ambiente `faixa`, que ocupa a largura total sem interromper o fluxo das
colunas:

```latex
\clearpage
\begin{faixa}
  \tabela{tabela2}
  \figura{figura2}
\end{faixa}
```

### Citações e referências

Cadastre as referências em `config/referencias.lua`:

```lua
{
  chave = "osada1972",
  autores = { { sobrenome = "Osada", nome = "J." } },
  ano = "1972",
  titulo = "Evolução das Ideias da Física",
  tipo = "livro",
  editora = "Editora Edgar Blücher Ltda",
  localidade = "SP",
}
```

Tipos aceitos: `artigo`, `livro`, `evento` e `web` (com `url` e `acesso`).
Para instituição, use `autores = { { instituicao = "Nome da Instituição" } }`.

No texto:

- `\citet{osada1972}` → `Osada (1972)`
- `\citep{osada1972}` → `(Osada, 1972)`
- `\citep{osada1972,giller1996}` → `(Osada, 1972; Giller & Turgeon, 1996)`

A lista é gerada por `\referencias` e ordenada alfabeticamente pelo sobrenome do
primeiro autor, ignorando acentos.

## Como as automações funcionam

`main.tex` carrega o módulo antes do documento:

```latex
\directlua{
  Relatorio = dofile("scripts/relatorio.lua")
  Relatorio.inicializar("config")
}
```

A classe define comandos que chamam funções Lua:

| Comando             | Função Lua               |
|---------------------|--------------------------|
| `\tabela{id}`       | `Relatorio.tabela(id)`   |
| `\figura{id}`       | `Relatorio.figura(id)`   |
| `\citet{chave}`     | `Relatorio.citar(...)`   |
| `\citep{chave}`     | `Relatorio.citar(...)`   |
| `\referencias`      | `Relatorio.referencias()`|

As funções leem os arquivos de `config/` e os CSV de `dados/`, montam o LaTeX e
o enviam ao documento com `tex.sprint`. Por isso, **compile a partir da raiz do
projeto**: os caminhos são relativos.

O módulo também registra o português e carrega os padrões de hifenização de
`scripts/hyph-pt.tex` por meio de `Relatorio.hifenizacao()`. Isso mantém a
hifenização correta mesmo em instalações do TeX Live sem o pacote
`hyphen-portuguese`.

## Formatação implementada

- A4, margens de 25 mm, duas colunas com 8 mm de separação.
- Times New Roman 12 pt (Liberation Serif como alternativa) e entrelinha
  simples.
- Título em Arial 14 pt negrito, centralizado; autores em negrito.
- Resumo em itálico logo abaixo do título, seguido de uma linha horizontal.
- Seções numeradas (`1.`, `2.`, ...), em maiúsculas e negrito; subseções
  (`2.1`, ...).
- Legendas de tabela acima e centralizadas; de figura abaixo e justificadas,
  ambas em 10 pt.
- Tabelas em 10 pt, com linhas horizontais e fonte alinhada à direita.
- Número de página em Arial negrito 10 pt no rodapé direito.
- Equações numeradas e com espaçamento adequado.
- PDF com metadados e links internos.

## Solução de problemas

- **`Relatorio` é `nil` ou arquivo não encontrado**: compile na raiz do projeto
  e confirme que `scripts/relatorio.lua` e `config/` existem.
- **Fonte diferente da esperada**: instale Times New Roman/Arial ou aceite a
  substituição por Liberation; confira o aviso no `main.log`.
- **Tabela larga fora de lugar**: use `\begin{faixa}...\end{faixa}` e
  `\clearpage` antes, como no exemplo do `main.tex`.
- **Caracteres estranhos em CSV**: salve em UTF-8 (o BOM é removido
  automaticamente).
- **Aviso `No hyphenation patterns were preloaded ... Portuguese`**: verifique
  se `scripts/hyph-pt.tex` existe e se `main.tex` chama
  `Relatorio.hifenizacao("scripts/hyph-pt.tex")` antes de `\begin{document}`.
  Com os padrões incluídos, esse aviso não deve aparecer.
