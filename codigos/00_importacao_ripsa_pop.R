#'---------------------------------------------------------
#'@projeto Tendencias demograficas da primeira infancia no estado do Piaui
#'@responsavel Thiago Cordeiro-Almeida
#'@script Thiago Cordeiro Almeida (CED/Espanha)
#'@ultima-atualizacao 2025-11-12
#'@dados RIPSA - populacao
#'@script Importacao, tratamento e exportacao da base
#'---------------------------------------------------------

# configuracoes gerais ----------------------------------------------------

options(scipen = 99999)
rm(list = ls())
invisible(gc())

# pacotes -----------------------------------------------------------------

library(pacman)
p_load(tidyverse, arrow, readxl)

# diretorios --------------------------------------------------------------

input_dir <- file.path("dados","ripsa","raw")


# processo ----------------------------------------------------------------

###
# definicao de parametros
###

ano = 2015
sexo = "feminino"

###
# importacao
###

df <- read_delim(
  file.path(input_dir, glue::glue("{sexo}_{ano}.txt")),
  delim = ";"
)

###
# manipulacao dos dados
###

df <- df |>
  mutate(
    cod_ibge_mun = str_extract(Município, "^[^ ]+"),
    cod_ibge_uf = str_sub(cod_ibge_mun, 1, 2),
    nome_mun = str_remove(Município, "^[^ ]+ "),
    .before = Município
  ) |>
  pivot_longer(
    `Menos que 1 ano de idade`:`80 anos e mais`,
    names_to = "idade",
    values_to = "populacao"
  ) |>
  select(cod_ibge_uf, cod_ibge_mun, nome_mun, idade, populacao)

# criacao de variaveis complementares

df <- df |>
  mutate(
    sexo = sexo,
    idade = str_remove(idade, " anos e mais"),
    idade = str_remove(idade, "  anos"),
    idade = str_remove(idade, " anos"),
    idade = str_remove(idade, "  ano"),
    idade = case_when(idade == "Menos que 1 ano de idade" ~ "0", TRUE ~ idade)
  ) |>
  mutate(
    across(c(cod_ibge_uf,cod_ibge_mun,idade), ~ as.numeric(.x))
  )

# Selecao de dados para o Piaui

df <- df |>
  filter(cod_ibge_uf == 22)
