local arquivo_pdf = arg[1] or "main.pdf"
local diretorio_saida = arg[2] or "main_png"
local resolucao = tonumber(arg[3] or "150")

local function encerrar(mensagem)
  io.stderr:write("Erro: " .. mensagem .. "\n")
  os.exit(1)
end

local function citar_shell(valor)
  return "'" .. tostring(valor):gsub("'", "'\\''") .. "'"
end

local function executar(comando, descricao)
  local sucesso, motivo, codigo = os.execute(comando)
  if sucesso ~= true and sucesso ~= 0 then
    encerrar(descricao .. " ("
      .. tostring(motivo or "erro") .. " " .. tostring(codigo or "") .. ")")
  end
end

if not resolucao or resolucao < 1 or resolucao % 1 ~= 0 then
  encerrar("a resolução deve ser um número inteiro positivo em DPI.")
end

local pdf = io.open(arquivo_pdf, "rb")
if not pdf then
  encerrar("PDF não encontrado: " .. arquivo_pdf)
end
pdf:close()

local verificacao = os.execute("command -v pdftoppm >/dev/null 2>&1")
if verificacao ~= true and verificacao ~= 0 then
  encerrar("pdftoppm não foi encontrado. Instale o Poppler para converter PDFs.")
end

executar("mkdir -p " .. citar_shell(diretorio_saida),
  "não foi possível criar o diretório de saída")

local nome = arquivo_pdf:match("([^/]+)$") or arquivo_pdf
nome = nome:gsub("%.[Pp][Dd][Ff]$", "")
local prefixo = diretorio_saida .. "/" .. nome
local comando = "pdftoppm -png -r " .. tostring(resolucao) .. " "
  .. citar_shell(arquivo_pdf) .. " " .. citar_shell(prefixo)

executar(comando, "falha ao converter " .. arquivo_pdf)
io.stdout:write("PNG gerados em " .. diretorio_saida .. " ("
  .. tostring(resolucao) .. " DPI).\n")
