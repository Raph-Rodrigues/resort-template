local M = {}
local graficos = dofile("scripts/relatorio/graficos.lua")

local function circuito()
  local codigo = [[
\begin{tikzpicture}[x=1cm,y=1cm,line cap=round,line join=round]
\definecolor{voltblue}{RGB}{153,204,255}
\draw[blue,line width=1pt] (0.8,5.2) -- (3.1,5.2);
\draw[blue,line width=1pt] (4.4,5.2) -- (12.2,5.2);
\draw[blue,line width=1pt] (0.8,0) -- (12.2,0);
\draw[blue,line width=1pt] (0.8,5.2) -- (0.8,3.55);
\draw[blue,line width=1pt] (0.8,1.65) -- (0.8,0);
\draw[blue,line width=1pt] (12.2,5.2) -- (12.2,3.55);
\draw[blue,line width=1pt] (12.2,1.65) -- (12.2,0);

\draw[fill=green,draw=black,line width=0.8pt] (3.1,5.02) rectangle (4.4,5.38);
\node[font=\Large\bfseries] at (3.75,4.65) {$R$};

\draw[fill=yellow,draw=black,line width=1.3pt] (0.8,2.6) circle (0.95);
\draw[fill=white,draw=black,line width=0.8pt] (0.3,2.72) rectangle (1.3,3.08);
\draw[line width=1.2pt] (0.8,2.9) -- (0.58,3.28);
\fill (0.8,2.9) circle (0.055);
\node[font=\Large\bfseries] at (0.8,2.05) {A};

\draw[fill=voltblue,draw=black,line width=1.3pt] (12.2,2.6) circle (0.95);
\draw[fill=white,draw=black,line width=0.8pt] (11.7,2.72) rectangle (12.7,3.08);
\draw[line width=1.2pt] (12.2,2.9) -- (12.42,3.28);
\fill (12.2,2.9) circle (0.055);
\node[font=\Large\bfseries] at (12.2,2.05) {V};

\draw[black,line width=1.3pt] (7.35,1.2) rectangle (8.65,4.15);
\draw[blue,line width=1pt] (8,5.2) -- (8,4.55);
\draw[blue,line width=1pt] (8,1.2) -- (8,0);
\draw[fill=black] (7.84,4.15) rectangle (8.16,4.38);
\draw[fill=black] (7.73,4.38) rectangle (8.27,4.55);
\draw[red,line width=1.2pt] (8,4.15) -- (8,3.35);
\draw[red,line width=1.2pt] (7.63,3.35) -- (8.37,3.35);
\draw[red,line width=1.2pt] (7.76,3.15) -- (8.24,3.15);
\draw[red,line width=1.2pt] (8,3.15) -- (8,2.42);
\draw[fill=red,draw=black,line width=0.8pt] (7.81,1.63) rectangle (8.19,2.42);
\draw[red,line width=1.2pt] (8,2.42) -- (8,1.2);
\node[font=\Large] at (8.48,3.52) {$+$};
\node[font=\Large\bfseries] at (9.05,3.12) {$V_p$};
\node[font=\Large\bfseries] at (8.46,1.95) {$r$};

\draw[->,line width=2pt] (5.34,3.4) arc[start angle=40,end angle=325,radius=1.55];
\node[font=\Large\bfseries] at (4.15,2.26) {$I$};
\end{tikzpicture}
]]
  for linha in codigo:gmatch("[^\n]+") do
    tex.sprint(linha)
  end
end

function M.imprimir(id, configuracoes)
  local figura = configuracoes[id]
  if not figura then
    error("Figura nao encontrada no config/figuras.lua: " .. tostring(id))
  end

  local larga = figura.larga and true or false
  if not larga then
    tex.sprint("\\begin{figure}[" .. (figura.posicao or "!htbp") .. "] ")
  else
    tex.sprint("\\begingroup ")
  end
  tex.sprint("\\setlength{\\parskip}{0pt}\\fontsize{10}{12}\\selectfont\\centering ")

  if figura.tipo == "grafico" then
    tex.sprint("\\resizebox{" .. (figura.largura or "\\columnwidth") .. "}{!}{")
    graficos.dispersao(figura)
    tex.sprint("} ")
  elseif figura.tipo == "circuito" then
    tex.sprint("\\resizebox{" .. (figura.largura or "\\textwidth") .. "}{!}{")
    circuito()
    tex.sprint("} ")
  elseif figura.arquivo then
    tex.sprint("\\includegraphics[width=" .. (figura.largura or "\\columnwidth")
      .. "]{" .. figura.arquivo .. "} ")
  else
    error("Tipo de figura nao suportado em config/figuras.lua: " .. tostring(figura.tipo))
  end

  if figura.legenda then
    tex.sprint(larga and "\\captionof{figure}{" .. figura.legenda .. "}"
      or "\\caption{" .. figura.legenda .. "}")
  end
  if figura.rotulo then
    tex.sprint("\\label{" .. figura.rotulo .. "}")
  end
  if larga then
    tex.sprint("\\par\\endgroup ")
  else
    tex.sprint("\\end{figure} ")
  end
end

return M
