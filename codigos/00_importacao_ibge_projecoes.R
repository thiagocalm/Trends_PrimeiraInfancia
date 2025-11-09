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

# codigos de selecao
codigos <- c(0,2,22)

# anos de selecao
presente <- c(2000:2024)
futuro <- c(2025:2040)

# Importacao ---------------------------------------------------

# importacao
df <- read_xlsx(
  file.path(dir_input,"projecoes_2024_tab1_idade_simples.xlsx"),
  skip = 5,
  col_names = TRUE
)

# Tratamentos -------------------------------------------------------------

# transformacao em formato longo

df <- df |>
  pivot_longer(
    `2000`:`2070`,
    names_to = "ano",
    values_to = "populacao"
  )

# ajuste de nomes das colunas

nomes <- c("idade","sexo","cod","sigla","local","ano","populacao")

colnames(df) <- nomes

# ajuste de classe das variaveis

df <- df |>
  mutate(
    ano = as.numeric(ano)
  )


# Selecao dos codigos de interesse ----------------------------------------

df <- df |>
  filter(cod %in% codigos)

# Divisao em duas bases de dados ------------------------------------------

# estimativas

df_estimativas <- df |>
  filter(ano %in% presente)

# projecoes

df_projecoes <- df |>
  filter(ano %in% futuro)


# Exportacao dos dados ----------------------------------------------------

# estimativas
write_parquet(
  df_estimativas,
  file.path(dir_output,"ibge_proj_uf_estimativas.parquet")
)

# estimativas
write_parquet(
  df_projecoes,
  file.path(dir_output,"ibge_proj_uf_projecoes.parquet")
)
