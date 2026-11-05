local M = {}

function M.imprimir(id, configuracoes, comum)
  local tabela = configuracoes[id]
  if not tabela then
    error("Tabela nao encontrada no config/tabelas.lua: " .. tostring(id))
  end

  tex.sprint("\\begingroup ")
  local _, registros = comum.ler_csv(tabela.arquivo)
  local colunas = tabela.colunas or {}
  local pesos = tabela.pesos or {}
  local especificacao = "|"
  for indice = 1, #colunas do
    local pre = "\\centering\\arraybackslash"
    if pesos[indice] then
      pre = "\\hsize=" .. tostring(pesos[indice]) .. "\\hsize" .. pre
    end
    especificacao = especificacao .. ">{" .. pre .. "}X|"
  end

  local larga = tabela.larga and true or false
  if not larga then
    tex.sprint("\\begin{table}[" .. (tabela.posicao or "!htbp") .. "] ")
  end
  tex.sprint("\\setlength{\\parskip}{0pt}\\setlength{\\tabcolsep}{1.9mm}"
    .. "\\fontsize{10}{12}\\selectfont\\hbadness=10000"
    .. "\\renewcommand{\\arraystretch}{" .. tostring(tabela.espacamento_linhas or 1.6)
    .. "}\\centering ")

  if larga then
    tex.sprint("\\begingroup ")
  end
  if tabela.legenda then
    tex.sprint(larga and "\\captionof{table}{" .. tabela.legenda .. "}"
      or "\\caption{" .. tabela.legenda .. "}")
  end
  if tabela.rotulo then
    tex.sprint("\\label{" .. tabela.rotulo .. "}")
  end
  if larga then
    tex.sprint("\\endgroup ")
  end

  tex.sprint(" \\begin{tabularx}{" .. (tabela.largura or "\\columnwidth")
    .. "}{" .. especificacao .. "} \\hline ")
  local cabecalho = {}
  for indice, coluna in ipairs(colunas) do
    cabecalho[indice] = "\\textbf{" .. (coluna.titulo or "") .. "}"
  end
  tex.sprint(table.concat(cabecalho, " & ") .. " \\\\ \\hline ")

  for _, registro in ipairs(registros) do
    local celulas = {}
    for indice, coluna in ipairs(colunas) do
      local formato = coluna.formato or "texto"
      if formato == "mais_menos" then
        local campos = coluna.campos or { coluna.campo, coluna.campo .. "_erro" }
        celulas[indice] = comum.numero_com_incerteza(
          registro[campos[1]] or "", registro[campos[2]] or "")
      elseif formato == "numero" or formato == "milhar" or formato == "decimal" then
        celulas[indice] = comum.numero(registro[coluna.campo] or "")
      else
        celulas[indice] = registro[coluna.campo] or ""
      end
    end
    tex.sprint(table.concat(celulas, " & ") .. " \\\\ \\hline ")
  end

  tex.sprint("\\end{tabularx} ")
  if tabela.fonte then
    tex.sprint("\\fonte{" .. tabela.fonte .. "} ")
  end
  if larga then
    tex.sprint("\\par\\vspace{12pt} ")
  else
    tex.sprint("\\end{table} ")
  end
  tex.sprint("\\endgroup ")
end

return M
