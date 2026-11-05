local M = {}

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
  local resultado = tostring(texto or ""):lower()
  for origem, destino in pairs(acentos) do
    resultado = resultado:gsub(origem, destino)
  end
  return resultado
end

local function chave_ordenacao(referencia)
  local autores = referencia.autores or {}
  local primeiro = autores[1] or {}
  local nome = primeiro.sobrenome or primeiro.instituicao
    or referencia.instituicao or ""
  return normalizar(nome) .. " " .. tostring(referencia.ano or "")
end

local function formatar_autores(autores)
  local lista = {}
  for _, autor in ipairs(autores or {}) do
    if autor.instituicao then
      lista[#lista + 1] = "\\MakeUppercase{" .. autor.instituicao .. "}"
    else
      lista[#lista + 1] = "\\MakeUppercase{" .. (autor.sobrenome or "")
        .. "}, " .. (autor.nome or "")
    end
  end
  if #lista == 0 then
    return ""
  elseif #lista == 1 then
    return lista[1]
  elseif #lista == 2 then
    return lista[1] .. " \\& " .. lista[2]
  end
  return table.concat(lista, "; ")
end

local function formatar_referencia(referencia)
  local autores = formatar_autores(referencia.autores)
  local titulo = "\\textbf{" .. (referencia.titulo or "") .. "}"
  local tipo = referencia.tipo or "livro"
  local entrada

  if tipo == "artigo" then
    entrada = autores .. "; " .. titulo
    if referencia.veiculo then
      entrada = entrada .. ", \\textit{" .. referencia.veiculo .. "}"
    end
    if referencia.volume then
      entrada = entrada .. ", v. " .. referencia.volume
    end
    if referencia.numero then
      entrada = entrada .. ", n. " .. referencia.numero
    end
    if referencia.paginas then
      entrada = entrada .. ", p. " .. referencia.paginas
    end
    return entrada .. " (" .. tostring(referencia.ano) .. ")."
  elseif tipo == "evento" then
    entrada = autores .. "; " .. titulo
    if referencia.veiculo then
      entrada = entrada .. ", " .. referencia.veiculo
    end
    if referencia.localidade then
      entrada = entrada .. ", " .. referencia.localidade
    end
    return entrada .. " (" .. tostring(referencia.ano) .. ")."
  elseif tipo == "web" then
    entrada = autores .. "; " .. titulo .. ";"
    if referencia.url then
      entrada = entrada .. " Disponível em \\url{" .. referencia.url .. "};"
    end
    if referencia.acesso then
      entrada = entrada .. " acesso em " .. referencia.acesso .. "."
    end
    return entrada
  end

  entrada = autores .. "; " .. titulo
  if referencia.editora then
    entrada = entrada .. ", " .. referencia.editora
  end
  if referencia.localidade then
    entrada = entrada .. ", " .. referencia.localidade
  end
  return entrada .. " (" .. tostring(referencia.ano) .. ")."
end

local function buscar(referencias, chave)
  for _, referencia in ipairs(referencias) do
    if referencia.chave == chave then
      return referencia
    end
  end
  error("Referencia nao encontrada no config/referencias.lua: " .. tostring(chave))
end

local function rotulo_autores(referencia)
  local autores = referencia.autores or {}
  if #autores == 0 then
    return referencia.instituicao or "Autor desconhecido"
  elseif autores[1].instituicao then
    return autores[1].instituicao
  elseif #autores == 1 then
    return autores[1].sobrenome or ""
  elseif #autores == 2 then
    return (autores[1].sobrenome or "") .. " \\& " .. (autores[2].sobrenome or "")
  end
  return (autores[1].sobrenome or "") .. " et al."
end

function M.citar(chaves, estilo, referencias)
  local partes = {}
  for chave in chaves:gmatch("[^,]+") do
    local referencia = buscar(referencias, (chave:gsub("^%s+", ""):gsub("%s+$", "")))
    local autor = rotulo_autores(referencia)
    if estilo == "parentese" then
      partes[#partes + 1] = autor .. ", " .. tostring(referencia.ano)
    else
      partes[#partes + 1] = autor .. " (" .. tostring(referencia.ano) .. ")"
    end
  end

  if estilo == "parentese" then
    tex.sprint("(" .. table.concat(partes, "; ") .. ")")
  else
    tex.sprint(table.concat(partes, #partes == 2 and " e " or "; "))
  end
end

function M.imprimir(referencias)
  local ordenadas = {}
  for _, referencia in ipairs(referencias) do
    ordenadas[#ordenadas + 1] = referencia
  end
  table.sort(ordenadas, function(a, b)
    return chave_ordenacao(a) < chave_ordenacao(b)
  end)

  tex.sprint("\\begingroup\\sloppy\\Urlmuskip=0mu plus 2mu"
    .. "\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{6pt} ")
  for _, referencia in ipairs(ordenadas) do
    tex.sprint("\\noindent\\hangindent=7.5mm\\hangafter=1 "
      .. formatar_referencia(referencia) .. "\\par ")
  end
  tex.sprint("\\endgroup ")
end

return M
