
# setup -------------------------------------------------------------------

rm(list = ls())

library(rgbif)
library(tidyverse)

# data --------------------------------------------------------------------

key <- 
  name_backbone("Abronia villosa") |> 
  pull(usageKey)


gbif_download <- 
  occ_download(
    pred("taxonKey", key),format = "SIMPLE_CSV",
    user = 'remyv' ,
    pwd = 'Lupin3ar!',
    email = 'remyv@ucr.edu')

occ_download_wa
gbif_download |>it(gbif_download)

gbif_download |> 
  write_rds("data/raw/key.rds")
 
  read_rds(
    file = "data/raw/key.rds")

data <- 
  occ_download_get(
    gbif_download, 
    path = 'data/raw', 
    overwrite = TRUE) |> 
  occ_download_import()

# save data ---------------------------------------------------------------

data |> 
  write_csv('data/raw/abronia_gbif_raw.csv')
