
# setup -------------------------------------------------------------------

rm(list = ls())

library(rinat)
library(tidyverse)

# data --------------------------------------------------------------------

#total of observations

inat_metadata <- 
  get_inat_obs(
    query = 'Pseudacris crucifer', 
    meta = TRUE) |> 
  pluck('meta')

inat_data <-
  get_inat_obs(
    query = 'Pseudacris crucifer',
    quality = 'research',
    geo = TRUE,
    maxresults = 10000,
    meta = FALSE) |> 
  as_tibble()

# save data ---------------------------------------------------------------

inat_data |> 
  write_csv('data/raw/pseudacris_inat_clean.csv')
