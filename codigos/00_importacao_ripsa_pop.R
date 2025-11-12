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
p_load(tidyverse, arrow, readxl, wpp2024)

# diretorios --------------------------------------------------------------

input_dir <- file.path("dados","ripsa","raw")
output_dir <- file.path("dados","ripsa")

# bases complementares ----------------------------------------------------

data("age5categories")

# Looping -----------------------------------------------------------------

###
# definicao de parametros
###

anos = 2015:2025
sexos = c("feminino","masculino","total")

for(s in seq_along(sexos)){
  # definicao de sexo
  sexo = sexos[s]
  for(i in seq_along(anos)){
    # definicao do ano
    ano = anos[i]
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

    # atribuindo variaveis como double
    df <- df |>
      mutate(
        across(c(`Menos que 1 ano de idade`:`80 anos e mais`), ~ as.numeric(.x))
      )

    # criando variaveis

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

    # juncao de dados de idade em categorias

    df <- df |>
      left_join(
        age5categories,
        by = c("idade" = "age1")
      ) |>
      rename(idade_5 = agecat, idade_5cat = age)

    # criacao de variaveis de idade para subgrupos

    df <- df |>
      mutate(
        ind_priminfancia = case_when(idade_5 == 0 ~ 1, TRUE ~ 0),
        ind_priminfancia_cat = case_when(
          idade %in% 0:3 ~ 1,
          idade %in% 4:5 ~ 2,
          TRUE ~ 0
        )
      )

    # proximo loop
    if(i == 1){
      df_anos = df
    } else{
      df_anos <- df_anos |> bind_rows(df)
    }
  }
  if(s == 1){
    dfs <- df_anos
  } else{
    dfs <- dfs |> bind_rows(df_anos)
  }
}


# ajustes de variaveis ----------------------------------------------------

dfs <- dfs |>
  select(cod_ibge_uf, cod_ibge_mun, nome_mun, sexo, idade, idade_5, idade_5cat, ind_priminfancia, ind_priminfancia_cat, populacao)

# exportacao --------------------------------------------------------------

write_parquet(
  dfs,
  file.path(output_dir, "ripsa_pop_munic.parquet")
)
