#'---------------------------------------------------------
#'@projeto Tendencias demograficas da primeira infancia no estado do Piaui
#'@responsavel Thiago Cordeiro-Almeida
#'@script Thiago Cordeiro Almeida (CED/Espanha)
#'@ultima-atualizacao 2025-11-13
#'@dados INEP - Sinopses
#'@script Importacao, tratamento e exportacao da base
#'---------------------------------------------------------

# configuracoes gerais ----------------------------------------------------

options(scipen = 99999)
rm(list = ls())
invisible(gc())

# pacotes -----------------------------------------------------------------

library(pacman)
p_load(tidyverse, arrow, readxl, basedosdados)

# diretorios --------------------------------------------------------------

input_dir <- file.path("dados","inep","raw")
output_dir <- file.path("dados","inep")

# importacao ----------------------------------------------

# parametros
anos = 2015:2024

for(i in seq_along(anos)){
  # parametro
  ano = anos[i]

  # importacao

  df <- read_xlsx(
    file.path(input_dir, "inep_sinopses.xlsx"),sheet = glue::glue("{ano}")
  )

  # limpando base

  df <- df |>
    filter(!is.na(cod))

  # criando variaveis

  df <- df |>
    rename(cod_ibge_mun = cod) |>
    mutate(
      cod_ibge_uf = str_sub(cod_ibge_mun, 1, 2),
      matricula_urbano = matricula_crerche_urbano + matricula_pre_urbano,
      matricula_rural = matricula_creche_rural + matricula_pre_rural,
      matricula_03 = matricula_creche_03 + matricula_pre_03,
      matricula_45 = matricula_creche_45 + matricula_pre_45,
      ano = ano
    ) |>
    select(ano, munic, cod_ibge_uf, everything())

  # selecionando casos

  df <- df |>
    filter(cod_ibge_uf == 22)

  # proximo loop
  if(i == 1){
    df_final = df
  } else{
    df_final = df_final |> bind_rows(df)
  }
}

# exportacao --------------------------------------------------------------

write_parquet(
  df_final,
  file.path(output_dir, "inep_sinopse_matricula.parquet")
)
