# Packages

library(readxl)
library(tidyverse)

#------------------------------------------------------------------------------------------------

## Residential consumption by energy source

# URL

URL <- paste0("http://www.epe.gov.br/sites-pt/publicacoes-dados-abertos/publicacoes/",
              "PublicacoesArquivos/publicacao-145/topico-134/",
              "Cap%C3%ADtulo%203%20(Consumo%20de%20Energia%20por%20Setor)%201970%20-%202018.xlsx")

if (!file.exists(paste0(tempdir(), "\\ben.xlsx"))) {
  download.file(URL, destfile = paste0(tempdir(), "\\ben.xlsx"), mode="wb")
}

# Read file

ben <- read_xlsx(paste0(tempdir(), "\\ben.xlsx"), skip = 192, n_max = 7)

# Clean data

ben <- ben %>% select(-SOURCES) 

ben <- ben %>% gather(ANO, CONSUMO, 2:ncol(ben))

ben <- ben %>% mutate(FONTES = as.factor(FONTES),
                      ANO = as.numeric(ANO))

levels(ben$FONTES) <- c("Carvao", "Eletricidade", "Gas", "GLP", "GN","Lenha", "Querosene")

names(ben) <- c("Fonte", "Ano", "Consumo")

ben <- ben %>% mutate(Unidade = "tep") %>% select(Ano, Fonte, Unidade, Consumo) 

#------------------------------------------------------------------------------------------------

## Residential consumption of electricity and LPG by Brazilian State

# Download e leitura

URL <- paste0("http://www.epe.gov.br/sites-pt/publicacoes-dados-abertos/publicacoes/",
              "PublicacoesArquivos/publicacao-145/topico-134/",
              "CAP%208%20%20(Dados%20Energ%C3%A9ticos%20Estaduais).xls")

if (!file.exists(paste0(tempdir(), "\\ben_estadual.xls"))) {
  download.file(URL, destfile = paste0(tempdir(), "\\ben_estadual.xls"), mode="wb")
}


## Electricity

ben_ee <- read_xls(paste0(tempdir(), "\\ben_estadual.xls"), sheet = "8.2",
                   skip = 3, n_max = 33)

ben_ee <- ben_ee %>% filter(!(ESTADO %in% c("BRASIL", "NORTE", "NORDESTE", "SUDESTE", "SUL", "CENTRO-OESTE"))) %>% 
          select(-STATE)

ben_ee <- ben_ee %>% gather(Ano, Consumo, 2:ncol(ben_ee)) %>% 
          mutate(Fonte = "EE", Unidade = "GWh")

## LPG

ben_glp <- read_xls(paste0(tempdir(), "\\ben_estadual.xls"), sheet = "8.3 ",
                    skip = 4, n_max = 33)

ben_glp <- ben_glp %>% filter(!(ESTADO %in% c("BRASIL", "NORTE", "NORDESTE", "SUDESTE", "SUL", "CENTRO OESTE"))) %>% 
           select(-STATE)

ben_glp <- ben_glp %>% gather(Ano, Consumo, 2:ncol(ben_glp)) %>% 
           mutate(Fonte = "GLP", Unidade = "mil m3")

## Merge

ben_state <- rbind(ben_ee, ben_glp)

# Fix variable and data

ben_state <- ben_state %>% mutate(Ano = as.numeric(Ano),
                                  Consumo = as.numeric(Consumo))

# Fix Espirito Santo name 

ben_state$ESTADO[ben_state$ESTADO == "Espirito Santo"] <- "Espírito Santo"

# Final

ben_state <- ben_state %>% select(Ano, UF = ESTADO, Fonte, Unidade, Consumo)

rm(ben_ee, ben_glp, URL)

#------------------------------------------------------------------------------------------------
