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
    ind_dom = as.numeric(paste0(upa, v1008, v1014)),
    ind_pes = as.numeric(paste0(ind_dom,v2003)),
    ind_priminfancia = case_when(idade %in% 0:5 ~ 1, TRUE ~ 0),
    ind_priminfancia_cat = case_when(
      idade %in% 0:3 ~ 1,
      idade %in% 4:5 ~ 2,
      TRUE ~ 0
    ),
    ind_brasil = 1,
    ind_regiao_NE = (uf %in% 20:29),
    ind_uf_PI = (uf == 22),
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
    ind_esc_freq = case_when(frequenta_creche == 1 | frequenta_preesc == 1 ~ 1, TRUE ~ 0),
    across(where(is.logical), as.numeric)
  )

# criando variavel de renda per capita

pnadc <- pnadc |>
  mutate(renda = case_when(is.na(renda) ~ 0, TRUE ~ renda)) |>
  mutate(
    pessoas = sum(ind_brasil),
    renda = sum(renda),
    .by = ind_dom
  ) |>
  # renda domiciliar per capita
  mutate(
    renda_pc = renda/pessoas
  )

# criando variaveis de renda ...

# selecionando variaveis

pnadc <- pnadc |>
  select(
    ano, uf, peso, ind_dom, ind_pes, idade, ind_situacao, ind_sexo, ind_priminfancia, ind_priminfancia_cat,
    ind_brasil, ind_regiao_NE, ind_uf_PI, ind_raca,
    #ind_renda,
    ind_esc_freq, frequenta_creche, frequenta_preesc
  )
