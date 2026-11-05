-- config/figuras.lua
-- Cada figura é incluída por \figura{id}.
--
-- Campos:
--   tipo    : "grafico" ou "circuito" para desenhos TikZ
--   arquivo : caminho opcional de uma imagem externa
--   pontos/eixos: dados e escalas para figuras do tipo "grafico"
--   legenda : texto da legenda (LaTeX permitido)
--   rotulo  : rótulo para \ref
--   largura : largura relativa, por exemplo 0.8\columnwidth
--   larga   : true para figure* (página inteira, topo da página seguinte)
--   posicao : opção de posicionamento do ambiente figure

return {
  figura1 = {
    tipo = "grafico",
    pontos = {
      { 0, 22 }, { 10800, 30 }, { 10800, 35 }, { 18000, 54 },
      { 30600, 40 }, { 45000, 62 }, { 79200, 65 }, { 108000, 95 },
    },
    eixo_x = { minimo = 0, maximo = 144000, passo = 36000, rotulo = "Tempo de estudo (\\si{\\second})" },
    eixo_y = { minimo = 20, maximo = 100, passo = 20, rotulo = "Nota da prova" },
    legenda = "Relação entre a nota da prova e o tempo de estudo. O tempo é expresso em segundos.",
    rotulo = "fig:notas",
    largura = "\\columnwidth",
    posicao = "H",
  },

  figura2 = {
    tipo = "circuito",
    legenda = "Esquema da montagem do circuito em série para a determinação da resistência interna da pilha. O Voltímetro (em azul) é montado em paralelo com a pilha e mede a voltagem $V = V_p + I\\,r$. O Amperímetro (em amarelo) é montado em série com a pilha e o resistor $R$ e mede a corrente $I = V_p/(R + r)$. Internamente (em vermelho) a pilha pode ser representada como uma fonte de voltagem contínua $V_p$ e uma resistência interna $r$. Fonte: autoria deste trabalho.",
    rotulo = "fig:circuito",
    largura = "0.99\\textwidth",
    larga = true,
    posicao = "!t",
  },

}
