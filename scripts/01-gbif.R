
# setup -------------------------------------------------------------------

library(rgbif)
library(tidyverse)

# data --------------------------------------------------------------------

key <- 
  name_backbone("Pseudacris crucifer") |> 
  pull(usageKey)


gbif_download <- 
  occ_download(
    pred("taxonKey", key),format = "SIMPLE_CSV")

gbif_download |> 
  read_rds(
    file = "data/raw/key.rds")

occ_download_wait(gbif_download)

d <- 
  occ_download_get(
    gbif_download, 
    path = 'data/raw', 
    overwrite = TRUE) |> 
  occ_download_import()

d |> 
  write_csv('data/raw/pseudacris_gbif_raw.csv')

