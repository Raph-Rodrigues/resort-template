# Compilação obrigatoriamente com LuaLaTeX.
$pdf_mode  = 4;   # 4 = LuaLaTeX
$dvi_mode  = 0;
$postscript_mode = 0;
$bibtex_use = 0;  # as referências são geradas pelo módulo Lua

# Remove também arquivos auxiliares menos comuns no "make clean".
$clean_ext = "bbl blg run.xml synctex.gz";
