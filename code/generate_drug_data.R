#load libraries
library(tidyverse)
library(here)
library(janitor)
library(corrr)
library(moderndive)
library(purrr)
library(webchem)

#rm(list=ls()) 

#NAMES-----
#This makes the names for drug search

#read current release information to set parameters for download
source(here::here("code", "current_release.R"))

time_begin_data <- Sys.time()

#censor drugs that have gene names #"lta", "nppb", "prima1"
censor_names <- c("LTA", "NPPB", "PRIMA1")
censor_ids <- c("brd_k52914072_001_01_5_2_5_mts004", "brd_k89272762_001_12_7_2_5_hts", "brd_k15318909_001_10_5_2_5_hts")

#get meta file
prism_meta <- read_csv(prismmeta_url, col_names = TRUE) %>% 
  clean_names() %>% 
  mutate(clean_drug = make_clean_names(column_name)) %>% 
  distinct(name, .keep_all = TRUE) %>%  #drop rows that have duplicate names
  filter(!name %in% censor_names) #censor 3 drugs from meta

# cids consists of "query" column and "cid" column
cids <- get_cid(prism_meta$name)
# or grab from
#cids <- readRDS(file=here::here("data", paste0(release, "_cids.Rds")))

cids <- 
  cids %>% distinct(query, .keep_all = TRUE)

prism_meta <- 
  prism_meta %>% 
  left_join(cids, by = c("name" = "query")) %>%  #"smiles" = "CanonicalSMILES"
  filter(!is.na(name))

#make name/join/search df
prism_names <- prism_meta %>% 
  select("name", "moa", "cid", "clean_drug")

#save files
saveRDS(prism_meta, file = here::here("data", paste0(release, "_prism_meta.Rds")))
saveRDS(prism_names, file = here::here("data", paste0(release, "_prism_names.Rds")))

#how long
time_end_data <- Sys.time()
