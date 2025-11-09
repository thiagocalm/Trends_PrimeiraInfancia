#'---------------------------------------------------------
#'@projeto Tendencias demograficas da primeira infancia no estado do Piaui
#'@responsavel Thiago Cordeiro-Almeida
#'@script Thiago Cordeiro Almeida (CED/Espanha)
#'@ultima-atualizacao 2025-11-09
#'@dados IBGE - projecoes
#'@script Importacao, tratamento e exportacao da base
#'---------------------------------------------------------

# configuracoes gerais ----------------------------------------------------

options(scipen = 99999)
rm(list = ls())
invisible(gc())

# pacotes -----------------------------------------------------------------

library(pacman)
p_load(tidyverse, arrow, readxl)

# Parametros --------------------------------------------------------------

# diretorio
dir_input = file.path("dados","ibge","projecoes","raw")
dir_output = file.path("dados","ibge","projecoes")

# Importacao ---------------------------------------------------

# importacao
df <- read_xlsx(
  file.path(dir_input,"projecoes_2024_tab1_idade_simples.xlsx"),
  skip = 5,
  col_names = TRUE
)

# Tratamentos -------------------------------------------------------------

