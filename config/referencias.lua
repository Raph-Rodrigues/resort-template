-- config/referencias.lua
-- Referências no formato autor (ano). A lista é ordenada alfabeticamente
-- pelo sobrenome do primeiro autor e formatada automaticamente.
--
-- Tipos: "artigo", "livro", "evento", "web".
-- Use LaTeX normalmente nos campos (por exemplo \textit, \url, acentos etc.).

return {
  {
    chave = "giller1996",
    autores = {
      { sobrenome = "Giller", nome = "M." },
      { sobrenome = "Turgeon", nome = "M." },
    },
    ano = "1996",
    titulo = "Método de aplicação geral para cálculo de incertezas sem correlação estatística",
    tipo = "evento",
    veiculo = "2º Seminário Internacional de Metrologia Elétrica",
    localidade = "Curitiba",
  },

  {
    chave = "osada1972",
    autores = {
      { sobrenome = "Osada", nome = "J." },
    },
    ano = "1972",
    titulo = "Evolução das Ideias da Física",
    tipo = "livro",
    editora = "Editora Edgar Blücher Ltda",
    localidade = "SP",
  },

  {
    chave = "unifei2014",
    autores = {
      { instituicao = "Instituto de Física-UNIFEI" },
    },
    ano = "2014",
    titulo = "Apostila de Metodologia Científica",
    tipo = "web",
    url = "http://www.unifei.edu.br/ifq/fisica/apometcie.html",
    acesso = "15/02/2014",
  },

  -- Exemplos adicionais de artigo (descomente e cite com \citet{...} ou
  -- \citep{...} se quiser testar a formatação).
  -- {
  --   chave = "satya1999",
  --   autores = {
  --     { sobrenome = "Satya", nome = "S." },
  --     { sobrenome = "Rao", nome = "R." },
  --     { sobrenome = "Kumar", nome = "K." },
  --   },
  --   ano = "1999",
  --   titulo = "Metodologia de análise de incertezas em experimentos didáticos",
  --   tipo = "artigo",
  --   veiculo = "Revista Brasileira de Ensino de Física",
  --   volume = "21",
  --   paginas = "45--52",
  -- },
}
