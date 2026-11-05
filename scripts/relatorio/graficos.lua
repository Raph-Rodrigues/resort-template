local M = {}

local function validar_eixos(eixo_x, eixo_y, pontos)
  if not eixo_x or not eixo_y or not pontos or #pontos < 2 then
    error("Grafico TikZ exige eixos e pelo menos dois pontos.")
  end
  if not eixo_x.passo or not eixo_y.passo
    or eixo_x.passo <= 0 or eixo_y.passo <= 0
    or eixo_x.maximo <= eixo_x.minimo or eixo_y.maximo <= eixo_y.minimo then
    error("Limites e passos invalidos nos eixos do grafico TikZ.")
  end
end

function M.dispersao(configuracao)
  local eixo_x, eixo_y, pontos =
    configuracao.eixo_x, configuracao.eixo_y, configuracao.pontos
  validar_eixos(eixo_x, eixo_y, pontos)

  local soma_x, soma_y, soma_xy, soma_x2 = 0, 0, 0, 0
  for _, ponto in ipairs(pontos) do
    local px, py = tonumber(ponto[1]), tonumber(ponto[2])
    if not px or not py then
      error("Cada ponto do grafico TikZ deve conter coordenadas numericas.")
    end
    soma_x, soma_y = soma_x + px, soma_y + py
    soma_xy, soma_x2 = soma_xy + px * py, soma_x2 + px * px
  end

  local quantidade = #pontos
  local denominador = quantidade * soma_x2 - soma_x * soma_x
  if denominador == 0 then
    error("Nao e possivel ajustar uma reta: todos os valores x sao iguais.")
  end
  local inclinacao = (quantidade * soma_xy - soma_x * soma_y) / denominador
  local intercepto = (soma_y - inclinacao * soma_x) / quantidade
  local function x(valor)
    return string.format("%.6f", 8 * (valor - eixo_x.minimo)
      / (eixo_x.maximo - eixo_x.minimo))
  end
  local function y(valor)
    return string.format("%.6f", 5 * (valor - eixo_y.minimo)
      / (eixo_y.maximo - eixo_y.minimo))
  end

  tex.sprint("\\begin{tikzpicture}[x=1cm,y=1cm]")
  for valor = eixo_x.minimo, eixo_x.maximo, eixo_x.passo do
    tex.sprint("\\draw[gray!45,dashed] (" .. x(valor) .. ",0) -- (" .. x(valor) .. ",5);")
    tex.sprint("\\node[below] at (" .. x(valor) .. ",0) {\\num{" .. tostring(valor) .. "}};")
  end
  for valor = eixo_y.minimo, eixo_y.maximo, eixo_y.passo do
    tex.sprint("\\draw[gray!45,dashed] (0," .. y(valor) .. ") -- (8," .. y(valor) .. ");")
    tex.sprint("\\node[left] at (0," .. y(valor) .. ") {\\num{" .. tostring(valor) .. "}};")
  end
  tex.sprint("\\draw[->,thick] (0,0) -- (8.2,0);\\draw[->,thick] (0,0) -- (0,5.2);")
  tex.sprint("\\node[below] at (4,-0.75) {" .. eixo_x.rotulo .. "};")
  tex.sprint("\\node[rotate=90] at (-1.0,2.5) {" .. eixo_y.rotulo .. "};")
  tex.sprint("\\begin{scope}\\clip (0,0) rectangle (8,5);")
  tex.sprint("\\draw[red,dashed,thick] (" .. x(eixo_x.minimo) .. ","
    .. y(inclinacao * eixo_x.minimo + intercepto) .. ") -- (" .. x(eixo_x.maximo)
    .. "," .. y(inclinacao * eixo_x.maximo + intercepto) .. ");")
  for _, ponto in ipairs(pontos) do
    tex.sprint("\\fill[blue] (" .. x(tonumber(ponto[1])) .. ","
      .. y(tonumber(ponto[2])) .. ") circle (2pt);")
  end
  tex.sprint("\\end{scope}\\end{tikzpicture}")
end

return M
