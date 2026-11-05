local comum = dofile("scripts/relatorio/comum.lua")
local tabelas = dofile("scripts/relatorio/tabelas.lua")
local figuras = dofile("scripts/relatorio/figuras.lua")
local referencias = dofile("scripts/relatorio/referencias.lua")
local idioma = dofile("scripts/relatorio/idioma.lua")

local M = {}

function M.inicializar(diretorio)
  diretorio = diretorio or "config"
  M.meta = comum.carregar_configuracao(diretorio .. "/relatorio.lua")
  M.tabelas_cfg = comum.carregar_configuracao(diretorio .. "/tabelas.lua")
  M.figuras_cfg = comum.carregar_configuracao(diretorio .. "/figuras.lua")
  M.refs_cfg = comum.carregar_configuracao(diretorio .. "/referencias.lua")
end

function M.hifenizacao(caminho)
  idioma.hifenizacao(caminho)
end

function M.titulo()
  return "\\MakeUppercase{" .. M.meta.titulo .. "}"
end

function M.autores()
  local linhas = {}
  for _, autor in ipairs(M.meta.autores or {}) do
    linhas[#linhas + 1] = "\\textbf{" .. autor.nome .. "-- matrícula "
      .. autor.matricula .. "}"
  end
  return table.concat(linhas, " \\\\ ")
end

function M.resumo()
  return M.meta.resumo or ""
end

function M.tabela(id)
  tabelas.imprimir(id, M.tabelas_cfg, comum)
end

function M.figura(id)
  figuras.imprimir(id, M.figuras_cfg)
end

function M.citar(chaves, estilo)
  referencias.citar(chaves, estilo, M.refs_cfg)
end

function M.referencias()
  referencias.imprimir(M.refs_cfg)
end

return M
