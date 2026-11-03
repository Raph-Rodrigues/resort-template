-- scripts/relatorio.lua
-- Automações em Lua para o template de relatório.
--
-- Funções expostas ao LaTeX:
--   Relatorio.titulo()        -> título em maiúsculas
--   Relatorio.autores()       -> linhas de autores/matrículas
--   Relatorio.resumo()        -> texto do resumo
--   Relatorio.tabela("id")    -> ambiente table/table* completo
--   Relatorio.figura("id")    -> ambiente figure/figure* completo
--   Relatorio.citar("a,b","texto"|"parentese")
--   Relatorio.referencias()   -> lista alfabética de referências

local M = {}

-- --------------------------------------------------------------------------
-- Utilidades
-- --------------------------------------------------------------------------

local function trim(s)
  return (tostring(s):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function load_config(path)
  local chunk, err = loadfile(path)
  if not chunk then
    error("Nao foi possivel carregar " .. path .. ": " .. tostring(err))
  end
  local ok, data = pcall(chunk)
  if not ok then
    error("Erro ao executar " .. path .. ": " .. tostring(data))
  end
  return data
end

local function read_file(path)
  local f, err = io.open(path, "r")
  if not f then
    error("Nao foi possivel abrir " .. path .. ": " .. tostring(err))
  end
  local data = f:read("*a")
  f:close()
  return data
end

-- --------------------------------------------------------------------------
-- Leitura de CSV (aceita vírgula ou ponto e vírgula como separador)
-- --------------------------------------------------------------------------

local function parse_csv_line(line, sep)
  local fields = {}

  local function push(value)
    fields[#fields + 1] = value
  end

  local i, n = 1, #line
  while true do
    if i > n then
      push("")
      break
    end

    if line:sub(i, i) == '"' then
      i = i + 1
      local buf = {}
      while i <= n do
        local ch = line:sub(i, i)
        if ch == '"' then
          if line:sub(i + 1, i + 1) == '"' then
            buf[#buf + 1] = '"'
            i = i + 2
          else
            i = i + 1
            break
          end
        else
          buf[#buf + 1] = ch
          i = i + 1
        end
      end
      push(table.concat(buf))
      while i <= n and line:sub(i, i) == " " do
        i = i + 1
      end
      if line:sub(i, i) == sep then
        i = i + 1
        if i > n then
          push("")
          break
        end
      else
        break
      end
    else
      local start = i
      while i <= n and line:sub(i, i) ~= sep do
        i = i + 1
      end
      push(trim(line:sub(start, i - 1)))
      if line:sub(i, i) == sep then
        i = i + 1
        if i > n then
          push("")
          break
        end
      else
        break
      end
    end
  end

  return fields
end

local function read_csv(path)
  local data = read_file(path)
  data = data:gsub("^\239\187\191", "") -- remove BOM UTF-8
  data = data:gsub("\r\n", "\n"):gsub("\r", "\n")

  local lines = {}
  for line in data:gmatch("[^\n]+") do
    local limpa = trim(line)
    if limpa ~= "" and not limpa:match("^#") then
      lines[#lines + 1] = line
    end
  end

  if #lines == 0 then
    return {}, {}
  end

  local sep = ","
  local _, commas = lines[1]:gsub(",", "")
  local _, semicolons = lines[1]:gsub(";", "")
  if semicolons > commas then
    sep = ";"
  end

  local header = parse_csv_line(lines[1], sep)
  local rows = {}
  for i = 2, #lines do
    local values = parse_csv_line(lines[i], sep)
    local row = {}
    for j = 1, #header do
      row[header[j]] = values[j] or ""
    end
    rows[#rows + 1] = row
  end

  return header, rows
end

-- --------------------------------------------------------------------------
-- Formatação numérica no padrão brasileiro
-- --------------------------------------------------------------------------

local function decimal_texto(value)
  local v = trim(value)
  if v == "" then
    return ""
  end
  if v:find(",", 1, true) then
    return v
  end
  return (v:gsub("%.", ","))
end

local function decimal_matematico(value)
  local v = trim(value)
  if v == "" then
    return ""
  end
  v = v:gsub(",", "{,}")
  v = v:gsub("%.", "{,}")
  return v
end

local function milhar(value)
  local v = trim(value)
  if v == "" then
    return ""
  end
  if not v:match("^%-?%d+$") then
    return decimal_texto(v)
  end
  local negativo = v:sub(1, 1) == "-"
  if negativo then
    v = v:sub(2)
  end
  local out = v:reverse():gsub("(%d%d%d)", "%1."):reverse()
  out = out:gsub("^%.", "")
  if negativo then
    out = "-" .. out
  end
  return out
end

local function mais_menos(valor, erro)
  return "$" .. decimal_matematico(valor) .. " \\pm " .. decimal_matematico(erro) .. "$"
end

-- --------------------------------------------------------------------------
-- Inicialização
-- --------------------------------------------------------------------------

function M.inicializar(dir)
  dir = dir or "config"
  M.meta = load_config(dir .. "/relatorio.lua")
  M.tabelas_cfg = load_config(dir .. "/tabelas.lua")
  M.figuras_cfg = load_config(dir .. "/figuras.lua")
  M.refs_cfg = load_config(dir .. "/referencias.lua")
end

-- --------------------------------------------------------------------------
-- Hifenização do português
-- --------------------------------------------------------------------------
-- O template inclui os padrões em scripts/hyph-pt.tex para não depender de
-- uma instalação específica do TeX Live. A babel é carregada em inglês e o
-- português é registrado aqui, antes de \begin{document}.
function M.hifenizacao(caminho)
  caminho = caminho or "scripts/hyph-pt.tex"

  local f = io.open(caminho, "r")
  if not f then
    tex.sprint("\\PackageWarning{relatorio}{Arquivo de hifenizacao nao encontrado: "
      .. caminho .. ". Usando a hifenizacao padrao.}")
    tex.sprint("\\babelprovide[import]{brazilian} ")
    return
  end
  f:close()

  tex.sprint("\\makeatletter ")
  tex.sprint("\\newlanguage\\relatorio@portugues ")
  tex.sprint("\\expandafter\\chardef\\csname l@brazilian\\endcsname=\\relatorio@portugues ")
  tex.sprint("\\expandafter\\chardef\\csname l@portuges\\endcsname=\\relatorio@portugues ")
  tex.sprint("\\language=\\relatorio@portugues ")
  tex.sprint("\\bbl@luapatterns{" .. caminho .. "}{} ")
  tex.sprint("\\makeatother ")
  tex.sprint("\\babelprovide[import]{brazilian} ")
end

-- --------------------------------------------------------------------------
-- Cabeçalho
-- --------------------------------------------------------------------------

function M.titulo()
  return "\\MakeUppercase{" .. M.meta.titulo .. "}"
end

function M.autores()
  local linhas = {}
  for _, autor in ipairs(M.meta.autores or {}) do
    linhas[#linhas + 1] = "\\textbf{" .. autor.nome .. "-- matrícula " .. autor.matricula .. "}"
  end
  return table.concat(linhas, " \\\\ ")
end

function M.resumo()
  return M.meta.resumo or ""
end

-- --------------------------------------------------------------------------
-- Tabelas
-- --------------------------------------------------------------------------

local function valor_celula(coluna, row)
  local formato = coluna.formato or "texto"

  if formato == "mais_menos" then
    local campos = coluna.campos
    if not campos then
      campos = { coluna.campo, coluna.campo .. "_erro" }
    end
    return mais_menos(row[campos[1]] or "", row[campos[2]] or "")
  elseif formato == "milhar" then
    return milhar(row[coluna.campo] or "")
  elseif formato == "decimal" then
    return decimal_texto(row[coluna.campo] or "")
  else
    return row[coluna.campo] or ""
  end
end

function M.tabela(id)
  local t = M.tabelas_cfg[id]
  if not t then
    error("Tabela nao encontrada no config/tabelas.lua: " .. tostring(id))
  end

  local _, rows = read_csv(t.arquivo)
  local colunas = t.colunas or {}
  local n = #colunas
  local pesos = t.pesos or {}

  local spec = "|"
  for i = 1, n do
    local pre = "\\centering\\arraybackslash"
    if pesos[i] then
      pre = "\\hsize=" .. tostring(pesos[i]) .. "\\hsize" .. pre
    end
    spec = spec .. ">{" .. pre .. "}X|"
  end

  local grande = t.larga and true or false
  local posicao = t.posicao or "!htbp"
  local largura = t.largura or "\\columnwidth"

  if not grande then
    tex.sprint("\\begin{table}[" .. posicao .. "] ")
  end
  tex.sprint("\\setlength{\\parskip}{0pt}\\setlength{\\tabcolsep}{1.9mm}\\fontsize{10}{12}\\selectfont\\hbadness=10000\\renewcommand{\\arraystretch}{" .. tostring(t.espacamento_linhas or 1.6) .. "}\\centering ")
  -- Em tabelas largas (fora de um ambiente table), a legenda e o rótulo são
  -- agrupados para que \@captype não vaze para a próxima legenda.
  if grande then
    tex.sprint("\\begingroup ")
  end
  if t.legenda then
    if grande then
      tex.sprint("\\captionof{table}{" .. t.legenda .. "}")
    else
      tex.sprint("\\caption{" .. t.legenda .. "}")
    end
  end
  if t.rotulo then
    tex.sprint("\\label{" .. t.rotulo .. "}")
  end
  if grande then
    tex.sprint("\\endgroup ")
  end
  tex.sprint(" \\begin{tabularx}{" .. largura .. "}{" .. spec .. "} ")
  tex.sprint("\\hline ")

  local cabecalho = {}
  for i = 1, n do
    cabecalho[#cabecalho + 1] = "\\textbf{" .. (colunas[i].titulo or "") .. "}"
  end
  tex.sprint(table.concat(cabecalho, " & ") .. " \\\\ ")
  tex.sprint("\\hline ")

  for _, row in ipairs(rows) do
    local celulas = {}
    for i = 1, n do
      celulas[#celulas + 1] = valor_celula(colunas[i], row)
    end
    tex.sprint(table.concat(celulas, " & ") .. " \\\\ ")
    tex.sprint("\\hline ")
  end

  tex.sprint("\\end{tabularx} ")
  if t.fonte then
    tex.sprint("\\fonte{" .. t.fonte .. "} ")
  end
  if grande then
    tex.sprint("\\par\\vspace{12pt} ")
  else
    tex.sprint("\\end{table} ")
  end
end

-- --------------------------------------------------------------------------
-- Figuras
-- --------------------------------------------------------------------------

function M.figura(id)
  local f = M.figuras_cfg[id]
  if not f then
    error("Figura nao encontrada no config/figuras.lua: " .. tostring(id))
  end

  local grande = f.larga and true or false
  local posicao = f.posicao or "!htbp"
  local largura = f.largura or "\\columnwidth"

  if not grande then
    tex.sprint("\\begin{figure}[" .. posicao .. "] ")
  end
  tex.sprint("\\setlength{\\parskip}{0pt}\\fontsize{10}{12}\\selectfont\\centering ")
  tex.sprint("\\includegraphics[width=" .. largura .. "]{" .. f.arquivo .. "} ")
  if grande then
    tex.sprint("\\begingroup ")
  end
  if f.legenda then
    if grande then
      tex.sprint("\\captionof{figure}{" .. f.legenda .. "}")
    else
      tex.sprint("\\caption{" .. f.legenda .. "}")
    end
  end
  if f.rotulo then
    tex.sprint("\\label{" .. f.rotulo .. "}")
  end
  if grande then
    tex.sprint("\\endgroup ")
  end
  if grande then
    tex.sprint("\\par ")
  else
    tex.sprint("\\end{figure} ")
  end
end

-- --------------------------------------------------------------------------
-- Citações no formato autor (ano) / (autor, ano)
-- --------------------------------------------------------------------------

local function buscar_referencia(chave)
  for _, ref in ipairs(M.refs_cfg) do
    if ref.chave == chave then
      return ref
    end
  end
  error("Referencia nao encontrada no config/referencias.lua: " .. tostring(chave))
end

local function rotulo_autores(ref)
  local autores = ref.autores or {}
  if #autores == 0 then
    return ref.instituicao or "Autor desconhecido"
  end
  if autores[1].instituicao then
    return autores[1].instituicao
  end
  local primeiro = autores[1].sobrenome or ""
  if #autores == 1 then
    return primeiro
  elseif #autores == 2 then
    return primeiro .. " \\& " .. (autores[2].sobrenome or "")
  else
    return primeiro .. " et al."
  end
end

function M.citar(chaves, estilo)
  local partes = {}
  for chave in chaves:gmatch("[^,]+") do
    local ref = buscar_referencia(trim(chave))
    local autor = rotulo_autores(ref)
    if estilo == "parentese" then
      partes[#partes + 1] = autor .. ", " .. tostring(ref.ano)
    else
      partes[#partes + 1] = autor .. " (" .. tostring(ref.ano) .. ")"
    end
  end

  if estilo == "parentese" then
    tex.sprint("(" .. table.concat(partes, "; ") .. ")")
  else
    local separador = (#partes == 2) and " e " or "; "
    tex.sprint(table.concat(partes, separador))
  end
end

-- --------------------------------------------------------------------------
-- Referências: ordenação alfabética e formatação
-- --------------------------------------------------------------------------

local acentos = {
  ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a",
  ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
  ["í"] = "i", ["ì"] = "i", ["î"] = "i", ["ï"] = "i",
  ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o",
  ["ú"] = "u", ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
  ["ç"] = "c", ["ñ"] = "n",
  ["Á"] = "a", ["À"] = "a", ["Â"] = "a", ["Ã"] = "a", ["Ä"] = "a",
  ["É"] = "e", ["È"] = "e", ["Ê"] = "e", ["Ë"] = "e",
  ["Í"] = "i", ["Ì"] = "i", ["Î"] = "i", ["Ï"] = "i",
  ["Ó"] = "o", ["Ò"] = "o", ["Ô"] = "o", ["Õ"] = "o", ["Ö"] = "o",
  ["Ú"] = "u", ["Ù"] = "u", ["Û"] = "u", ["Ü"] = "u",
  ["Ç"] = "c", ["Ñ"] = "n"
}

local function normalizar(texto)
  local s = tostring(texto or ""):lower()
  for de, para in pairs(acentos) do
    s = s:gsub(de, para)
  end
  return s
end

local function chave_ordenacao(ref)
  local autores = ref.autores or {}
  local primeiro = autores[1] or {}
  local nome = primeiro.sobrenome or primeiro.instituicao or ref.instituicao or ""
  return normalizar(nome) .. " " .. tostring(ref.ano or "")
end

local function formatar_autores(autores)
  local lista = {}
  for _, autor in ipairs(autores or {}) do
    if autor.instituicao then
      lista[#lista + 1] = "\\MakeUppercase{" .. autor.instituicao .. "}"
    else
      lista[#lista + 1] = "\\MakeUppercase{" .. (autor.sobrenome or "") .. "}, " .. (autor.nome or "")
    end
  end

  if #lista == 0 then
    return ""
  elseif #lista == 1 then
    return lista[1]
  elseif #lista == 2 then
    return lista[1] .. " \\& " .. lista[2]
  else
    return table.concat(lista, "; ")
  end
end

local function formatar_referencia(ref)
  local autores = formatar_autores(ref.autores)
  local titulo = "\\textbf{" .. (ref.titulo or "") .. "}"
  local tipo = ref.tipo or "livro"
  local entrada

  if tipo == "artigo" then
    entrada = autores .. "; " .. titulo
    if ref.veiculo then
      entrada = entrada .. ", \\textit{" .. ref.veiculo .. "}"
    end
    if ref.volume then
      entrada = entrada .. ", v. " .. ref.volume
    end
    if ref.numero then
      entrada = entrada .. ", n. " .. ref.numero
    end
    if ref.paginas then
      entrada = entrada .. ", p. " .. ref.paginas
    end
    entrada = entrada .. " (" .. tostring(ref.ano) .. ")."
  elseif tipo == "evento" then
    entrada = autores .. "; " .. titulo
    if ref.veiculo then
      entrada = entrada .. ", " .. ref.veiculo
    end
    if ref.localidade then
      entrada = entrada .. ", " .. ref.localidade
    end
    entrada = entrada .. " (" .. tostring(ref.ano) .. ")."
  elseif tipo == "web" then
    entrada = autores .. "; " .. titulo .. ";"
    if ref.url then
      entrada = entrada .. " Disponível em \\url{" .. ref.url .. "};"
    end
    if ref.acesso then
      entrada = entrada .. " acesso em " .. ref.acesso .. "."
    end
  else
    entrada = autores .. "; " .. titulo
    if ref.editora then
      entrada = entrada .. ", " .. ref.editora
    end
    if ref.localidade then
      entrada = entrada .. ", " .. ref.localidade
    end
    entrada = entrada .. " (" .. tostring(ref.ano) .. ")."
  end

  return entrada
end

function M.referencias()
  local refs = {}
  for _, ref in ipairs(M.refs_cfg) do
    refs[#refs + 1] = ref
  end

  table.sort(refs, function(a, b)
    return chave_ordenacao(a) < chave_ordenacao(b)
  end)

  tex.sprint("\\begingroup\\sloppy\\Urlmuskip=0mu plus 2mu\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{6pt} ")
  for _, ref in ipairs(refs) do
    tex.sprint("\\noindent\\hangindent=7.5mm\\hangafter=1 "
      .. formatar_referencia(ref) .. "\\par ")
  end
  tex.sprint("\\endgroup ")
end

return M
