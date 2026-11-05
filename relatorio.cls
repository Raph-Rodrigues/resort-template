%% relatorio.cls
%% Template de relatório científico em conformidade com o arquivo
%% "Relatoriomassa.doc" (A4, 2 colunas, Times 12 pt, Arial no título).
%%
%% Compile com LuaLaTeX (obrigatório: há automações em Lua).
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{relatorio}[2026/11/03 v1.0 Template de relatório com automações em Lua]

\LoadClass[12pt,a4paper,twocolumn]{article}

% --------------------------------------------------------------------------
% Geometria: A4, margens de 25 mm, duas colunas com 8 mm de separação.
% --------------------------------------------------------------------------
\RequirePackage{geometry}
\geometry{
  a4paper,
  left=25mm,
  right=25mm,
  top=25mm,
  bottom=25mm,
  columnsep=8mm,
  headheight=0pt,
  headsep=0pt,
  footskip=10mm
}

% --------------------------------------------------------------------------
% Tipografia: Times New Roman no texto e Arial no título/paginacão.
% Se as fontes da Microsoft não estiverem instaladas, usa-se Liberation.
% --------------------------------------------------------------------------
\RequirePackage{fontspec}
\IfFontExistsTF{Times New Roman}
  {\setmainfont{Times New Roman}}
  {\setmainfont{Liberation Serif}}
\IfFontExistsTF{Arial}
  {\setsansfont{Arial}}
  {\setsansfont{Liberation Sans}}

\RequirePackage{unicode-math}
\setmathfont{TeX Gyre Termes Math}

% O português é habilitado em main.tex por Relatorio.hifenizacao(), que
% carrega os padrões incluídos em scripts/hyph-pt.tex. Assim o template
% funciona mesmo em instalações sem o pacote de hifenização do português.
\RequirePackage[english]{babel}
\RequirePackage{microtype}

% Entrelinha simples do Word (aproximadamente 13,8 pt para 12 pt).
\linespread{0.95}

% Parágrafos: recuo de 7,5 mm e 6 pt antes, sem espaço depois.
\setlength{\parindent}{7.5mm}
\setlength{\parskip}{6pt}
\setlength{\emergencystretch}{1.5em}
\raggedbottom
\setlength{\columnseprule}{0pt}

% --------------------------------------------------------------------------
% Pacotes de apoio.
% --------------------------------------------------------------------------
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{siunitx}
\sisetup{
  input-decimal-markers = {.},
  output-decimal-marker = {,},
  group-separator = {.},
  group-minimum-digits = 4,
  per-mode = symbol,
  mode = match
}
\RequirePackage{array}
\RequirePackage{tabularx}
\RequirePackage{float}
\RequirePackage{cuted}
\setlength{\stripsep}{0pt}
\RequirePackage{caption}
\RequirePackage{titlesec}
\RequirePackage{fancyhdr}
\RequirePackage{indentfirst}
\RequirePackage{enumitem}
\RequirePackage{hyperref}
\urlstyle{same}

\hypersetup{
  colorlinks=true,
  linkcolor=black,
  citecolor=black,
  urlcolor=black,
  pdfsubject={Relatório científico},
  pdfcreator={LuaLaTeX}
}

% --------------------------------------------------------------------------
% Seções: numeral seguido de ponto, título em versalete maiúsculo,
% fonte Times New Roman em negrito, 12 pt.
% --------------------------------------------------------------------------
\titleformat{\section}[hang]
  {\normalfont\bfseries\hyphenpenalty=10000\exhyphenpenalty=10000}
  {\thesection.}
  {1.05em}
  {\MakeUppercase}
\titlespacing*{\section}{0pt}{12pt}{6pt}

\titleformat{\subsection}[hang]
  {\normalfont\bfseries\hyphenpenalty=10000\exhyphenpenalty=10000}
  {\thesubsection}
  {0.6em}
  {}
\titlespacing*{\subsection}{0pt}{12pt}{6pt}

% --------------------------------------------------------------------------
% Legendas: 10 pt, rótulo em negrito, separador travessão.
% Tabelas: legenda acima e centralizada. Figuras: legenda abaixo e justificada.
% --------------------------------------------------------------------------
\captionsetup{
  font=footnotesize,
  labelfont=bf,
  labelsep=endash,
  justification=justified,
  singlelinecheck=false,
  skip=4pt,
  parskip=0pt,
  hypcap=false
}
\captionsetup[table]{position=top, justification=centering, skip=3pt}
\captionsetup[figure]{position=bottom, justification=justified, skip=5pt}

% --------------------------------------------------------------------------
% Rodapé: número da página em Arial negrito 10 pt, alinhado à direita.
% --------------------------------------------------------------------------
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}
\fancyfoot[R]{\sffamily\bfseries\fontsize{10}{12}\selectfont\thepage}

% --------------------------------------------------------------------------
% Espaçamento das equações.
% --------------------------------------------------------------------------
\AtBeginDocument{%
  \setlength{\abovedisplayskip}{6pt}%
  \setlength{\belowdisplayskip}{6pt}%
  \setlength{\abovedisplayshortskip}{3pt}%
  \setlength{\belowdisplayshortskip}{3pt}%
}

% --------------------------------------------------------------------------
% Interface com as automações em Lua.
% O documento principal deve executar, antes de \begin{document}:
%
%   \directlua{
%     Relatorio = dofile("scripts/relatorio.lua")
%     Relatorio.inicializar("config")
%   }
% --------------------------------------------------------------------------
\makeatletter

\newcommand{\imprimirtitulo}{\directlua{tex.sprint(Relatorio.titulo())}}
\newcommand{\imprimirautores}{\directlua{tex.sprint(Relatorio.autores())}}
\newcommand{\imprimirresumo}{\directlua{tex.sprint(Relatorio.resumo())}}

\renewcommand{\maketitle}{%
  \twocolumn[{%
    \begin{@twocolumnfalse}
      \vspace*{-5.5mm}
      \begin{center}
        {\sffamily\bfseries\fontsize{14}{16.8}\selectfont
          \imprimirtitulo\par}
        \vspace{12pt}
        {\bfseries\fontsize{12}{14}\selectfont
          \begin{tabular}[t]{c}
            \imprimirautores
          \end{tabular}\par}
      \end{center}
      \vspace{10pt}
      {\itshape\fontsize{12}{13.8}\selectfont
        \setlength{\parindent}{0pt}%
        \noindent\textbf{Resumo.}\ \imprimirresumo\par}
      \vspace{10pt}
      {\color{black!50}\rule{\textwidth}{1.45pt}}
      \vspace{1pt}
    \end{@twocolumnfalse}
  }]%
  \thispagestyle{fancy}%
}

% Fonte de tabela: alinhada à direita, 10 pt.
\newenvironment{faixa}{\begin{strip}\vspace*{-12pt}}{\end{strip}}

\newcommand{\fonte}[1]{%
  \par\vspace{2pt}%
  {\footnotesize\raggedleft #1\par}%
}

% Comandos de automação em Lua.
\newcommand{\tabela}[1]{\directlua{Relatorio.tabela("#1")}}
\newcommand{\figura}[1]{\directlua{Relatorio.figura("#1")}}
\newcommand{\citet}[1]{\directlua{Relatorio.citar("#1","texto")}}
\newcommand{\citep}[1]{\directlua{Relatorio.citar("#1","parentese")}}
\renewcommand{\cite}[1]{\citep{#1}}
\newcommand{\referencias}{\directlua{Relatorio.referencias()}}

\makeatother

\endinput
