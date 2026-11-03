-- config/tabelas.lua
-- Cada tabela é montada automaticamente a partir de um CSV.
--
-- Campos:
--   arquivo   : caminho do CSV (a primeira linha contém os nomes das colunas)
--   legenda   : texto da legenda (LaTeX permitido)
--   rotulo    : rótulo para \ref
--   fonte     : texto da fonte, alinhado à direita
--   largura   : \columnwidth (uma coluna) ou \textwidth (página inteira)
--   larga     : true para table* (flutua no topo da página seguinte)
--   posicao   : opção de posicionamento do ambiente table
--   pesos     : proporção opcional das colunas (a soma deve ser o nº de colunas)
--   colunas   : lista de colunas com título, campo e formato
--
-- Formatos disponíveis:
--   texto      -> valor literal do CSV
--   milhar     -> 5641 vira 5.641
--   decimal    -> 9.1 vira 9,1
--   mais_menos -> usa dois campos (valor e erro) no formato 9,1 ± 0,2

return {
  tabela1 = {
    arquivo = "dados/tabela1.csv",
    legenda = "Evolução do Eleitorado de Santa Rita da Perpétua Agonia do Sapucaí Mirim do Norte",
    rotulo = "tab:eleitorado",
    fonte = "TRE-MG",
    largura = "\\columnwidth",
    posicao = "H",
    colunas = {
      { titulo = "Ano", campo = "ano", formato = "texto" },
      { titulo = "Número de Eleitores", campo = "eleitores", formato = "milhar" },
    },
  },

  tabela2 = {
    arquivo = "dados/tabela2.csv",
    legenda = "Ensaios para Determinar a Aceleração da Gravidade através de um Pêndulo",
    rotulo = "tab:pendulo",
    fonte = "Laboratório de Física -- UNIFEI",
    largura = "\\textwidth",
    larga = true,
    posicao = "!t",
    espacamento_linhas = 1.75,
    pesos = { 0.82, 1.05, 1.05, 1.05, 1.03 },
    colunas = {
      { titulo = "Ensaio", campo = "ensaio", formato = "texto" },
      { titulo = "$\\symbf{L}$ ($\\pm$ 0,001) (m)", campo = "L", campos = { "L", "L_erro" }, formato = "mais_menos" },
      { titulo = "$\\symbf{P}$ ($\\pm$ 0,02) (s)", campo = "P", campos = { "P", "P_erro" }, formato = "mais_menos" },
      { titulo = "$\\symbf{g}$ (m/s$^2$)", campo = "g", campos = { "g", "g_erro" }, formato = "mais_menos" },
      { titulo = "E.A. (\\%)", campo = "EA", formato = "decimal" },
    },
  },
}
