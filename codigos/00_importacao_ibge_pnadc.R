#'---------------------------------------------------------
#'@projeto Tendencias demograficas da primeira infancia no estado do Piaui
#'@responsavel Thiago Cordeiro-Almeida
#'@script Thiago Cordeiro Almeida (CED/Espanha)
#'@ultima-atualizacao 2025-11-12
#'@dados IBGE - PNADC
#'@script Importacao, tratamento e exportacao da base
#'---------------------------------------------------------

# configuracoes gerais ----------------------------------------------------

options(scipen = 99999)
rm(list = ls())
invisible(gc())

# pacotes -----------------------------------------------------------------

library(pacman)
p_load(tidyverse, arrow, readxl, PNADcIBGE)


# diretorios --------------------------------------------------------------

input_dir <- file.path("dados","ibge","pnadc")

# Processo ----------------------------------------------------------------

###
# Definicao de parametros
###

# ano
ano = 2015

# visita
if(ano %in% c(2015:2019,2022:2024)){
  visita = 1
} else{
  visita = 5
}

###
# Importacao dos dados
###

# importacao dos dados

pnadc <- read_parquet(
  file.path(input_dir, glue::glue("pnadc_{ano}_visita_{visita}.parquet"))
)

# criando variaveis de interesse

pnadc <- pnadc |>
  rename(
    peso = v1032,
    idade = v2009,
    ind_situacao = v1022,
    ind_sexo = v2007
  ) |>
  mutate(
    ind_dom = paste0()
    ind_priminfancia = case_when(idade %in% 0:5 ~ 1, TRUE ~ 0),
    ind_priminfancia_cat = case_when(
      idade %in% 0:3 ~ 1,
      idade %in% 4:5 ~ 2,
      TRUE ~ 0
    ),
    ind_brasil = 1,
    ind_regiao_NE = (uf %in% 20:29),
    ind_raca = case_when(
      v2010 %in% c(2, 4) ~ 1,
      v2010 %in% c(5) ~ 2,
      v2010 %in% c(1, 3) ~ 0,
      TRUE ~ NA_real_),
    # falta renda
    renda = vd4019,

    # falta escolaridade

    frequenta_creche = case_when(v3003a %in% 1:2 ~ 1, TRUE ~ 0),
    frequenta_preesc = case_when(v3003a >= 2 ~ 1, TRUE ~ 0),
    across(where(is.logical), as.numeric)
  )

# selecionando variaveis

