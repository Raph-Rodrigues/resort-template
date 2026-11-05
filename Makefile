# Makefile do template de relatório (LuaLaTeX)

MAIN     = main
LATEXMK  = latexmk
TARGET   = $(MAIN).pdf

SOURCES = $(MAIN).tex relatorio.cls \
          scripts/relatorio.lua \
          $(wildcard scripts/relatorio/*.lua) \
          scripts/hyph-pt.tex \
          $(wildcard config/*.lua) \
          $(wildcard dados/*.csv) \
          $(wildcard figuras/*)

.PHONY: all clean distclean

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(LATEXMK) -lualatex -interaction=nonstopmode -halt-on-error $(MAIN).tex

clean:
	$(LATEXMK) -c $(MAIN).tex

distclean:
	$(LATEXMK) -C $(MAIN).tex
