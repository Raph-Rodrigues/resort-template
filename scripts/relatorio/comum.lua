local M = {}

function M.trim(texto)
  return (tostring(texto):gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.carregar_configuracao(caminho)
  local chunk, erro = loadfile(caminho)
  if not chunk then
    error("Nao foi possivel carregar " .. caminho .. ": " .. tostring(erro))
  end
  local ok, dados = pcall(chunk)
  if not ok then
    error("Erro ao executar " .. caminho .. ": " .. tostring(dados))
  end
  return dados
end

local function ler_arquivo(caminho)
  local arquivo, erro = io.open(caminho, "r")
  if not arquivo then
    error("Nao foi possivel abrir " .. caminho .. ": " .. tostring(erro))
  end
  local dados = arquivo:read("*a")
  arquivo:close()
  return dados
end

local function analisar_linha_csv(linha, separador)
  local campos = {}
  local indice, tamanho = 1, #linha

  while true do
    if indice > tamanho then
      campos[#campos + 1] = ""
      break
    end

    if linha:sub(indice, indice) == '"' then
      indice = indice + 1
      local buffer = {}
      while indice <= tamanho do
        local caractere = linha:sub(indice, indice)
        if caractere == '"' then
          if linha:sub(indice + 1, indice + 1) == '"' then
            buffer[#buffer + 1] = '"'
            indice = indice + 2
          else
            indice = indice + 1
            break
          end
        else
          buffer[#buffer + 1] = caractere
          indice = indice + 1
        end
      end
      campos[#campos + 1] = table.concat(buffer)
      while indice <= tamanho and linha:sub(indice, indice) == " " do
        indice = indice + 1
      end
      if linha:sub(indice, indice) == separador then
        indice = indice + 1
        if indice > tamanho then
          campos[#campos + 1] = ""
          break
        end
      else
        break
      end
    else
      local inicio = indice
      while indice <= tamanho and linha:sub(indice, indice) ~= separador do
        indice = indice + 1
      end
      campos[#campos + 1] = M.trim(linha:sub(inicio, indice - 1))
      if linha:sub(indice, indice) == separador then
        indice = indice + 1
        if indice > tamanho then
          campos[#campos + 1] = ""
          break
        end
      else
        break
      end
    end
  end
  return campos
end

function M.ler_csv(caminho)
  local dados = ler_arquivo(caminho)
  dados = dados:gsub("^\239\187\191", ""):gsub("\r\n", "\n"):gsub("\r", "\n")

  local linhas = {}
  for linha in dados:gmatch("[^\n]+") do
    local limpa = M.trim(linha)
    if limpa ~= "" and not limpa:match("^#") then
      linhas[#linhas + 1] = linha
    end
  end
  if #linhas == 0 then
    return {}, {}
  end

  local _, virgulas = linhas[1]:gsub(",", "")
  local _, ponto_virgulas = linhas[1]:gsub(";", "")
  local separador = ponto_virgulas > virgulas and ";" or ","
  local cabecalho = analisar_linha_csv(linhas[1], separador)
  local registros = {}
  for indice = 2, #linhas do
    local valores = analisar_linha_csv(linhas[indice], separador)
    local registro = {}
    for coluna, nome in ipairs(cabecalho) do
      registro[nome] = valores[coluna] or ""
    end
    registros[#registros + 1] = registro
  end
  return cabecalho, registros
end

function M.numero(valor)
  local texto = M.trim(valor)
  if texto == "" then
    return ""
  end
  texto = texto:gsub(",", ".")
  return "\\num{" .. texto .. "}"
end

function M.numero_com_incerteza(valor, erro)
  return M.numero(valor) .. " $\\pm$ " .. M.numero(erro)
end

return M
