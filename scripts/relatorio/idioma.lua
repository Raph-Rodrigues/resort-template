local M = {}

function M.hifenizacao(caminho)
  caminho = caminho or "scripts/hyph-pt.tex"
  local arquivo = io.open(caminho, "r")
  if not arquivo then
    tex.sprint("\\PackageWarning{relatorio}{Arquivo de hifenizacao nao encontrado: "
      .. caminho .. ". Usando a hifenizacao padrao.}")
    tex.sprint("\\babelprovide[import]{brazilian} ")
    return
  end
  arquivo:close()

  tex.sprint("\\makeatletter ")
  tex.sprint("\\newlanguage\\relatorio@portugues ")
  tex.sprint("\\expandafter\\chardef\\csname l@brazilian\\endcsname=\\relatorio@portugues ")
  tex.sprint("\\expandafter\\chardef\\csname l@portuges\\endcsname=\\relatorio@portugues ")
  tex.sprint("\\language=\\relatorio@portugues ")
  tex.sprint("\\bbl@luapatterns{" .. caminho .. "}{} ")
  tex.sprint("\\makeatother ")
  tex.sprint("\\babelprovide[import]{brazilian} ")
end

return M
