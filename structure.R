folders <- c('data/raw',
             'data/processed',
             'shapefiles',
             'shapefiles/processed',
             'rasters',
             'scripts',
             'outputs/figures',
             'outputs/tables',
             'docs')

sapply(folders,
       FUN = dir.create,
       recursive = TRUE)