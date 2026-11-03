-- config/figuras.lua
-- Cada figura é incluída por \figura{id}.
--
-- Campos:
--   arquivo : caminho da imagem
--   legenda : texto da legenda (LaTeX permitido)
--   rotulo  : rótulo para \ref
--   largura : largura relativa, por exemplo 0.8\columnwidth
--   larga   : true para figure* (página inteira, topo da página seguinte)
--   posicao : opção de posicionamento do ambiente figure

return {
  figura1 = {
    arquivo = "figuras/figura1.png",
    legenda = "Relação entre a Nota da Prova de Metodologia Científica e as horas dedicadas a estudo da disciplina, por parte dos alunos. Fonte: estudo exploratório deste trabalho.",
    rotulo = "fig:notas",
    largura = "\\columnwidth",
    posicao = "H",
  },

  figura2 = {
    arquivo = "figuras/figura2.png",
    legenda = "Esquema da montagem do circuito em série para a determinação da resistência interna da pilha. O Voltímetro (em azul) é montado em paralelo com a pilha e mede a voltagem $V = V_p + I\\,r$. O Amperímetro (em amarelo) é montado em série com a pilha e o resistor $R$ e mede a corrente $I = V_p/(R + r)$. Internamente (em vermelho) a pilha pode ser representada como uma fonte de voltagem contínua $V_p$ e uma resistência interna $r$. Fonte: autoria deste trabalho.",
    rotulo = "fig:circuito",
    largura = "0.99\\textwidth",
    larga = true,
    posicao = "!t",
  },
}
