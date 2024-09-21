# Hector Zumbado
# packages needed to run the project

# setup -------------------------------------------------------------------

rm(list = ls())

ipak <- 
  function(pkg){
    new.pkg <- 
      pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
      install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)}

packages <- 
  c(
    'renv',
    'rmarkdown',
    'quarto',
    'janitor',
    'rinat',
    'tidyverse', 
    'rgbif',
    'CoordinateCleaner',
    'tmap',
    'tmaptools',
    'sf',
    'terra',
    'remotes',
    'usethis')

ipak(packages)

#other packages

remotes::install_github("ropensci/scrubr")
