# setup -------------------------------------------------------------------

rm(list = ls())

library(sf)
library(terra)
library(tmap)
library(tidyverse)

# data --------------------------------------------------------------------

world <- 
  read_sf('shapefiles/world.gpkg') |> 
  st_make_valid() 

list.files(
  'shapefiles',
  pattern = 'cou|usa',
  full.names = TRUE) |> 
  map(~ .x |> 
        read_sf()) |> 
  set_names('counties','usa') |>
  map(~ .x |> 
        st_transform(
          crs = st_crs(world))) |> 
  list2env(.GlobalEnv)

# conterminous us ---------------------------------------------------------

usa |>
  distinct(name) |>
  pull()

usa_cont <- 
  usa |> 
  rename(state = name) |> 
  filter(!state %in% c(
    'Hawaii', 
    'Alaska',
    'Guam',
    'Commonwealth of the Northern Mariana Islands',
    'United States Virgin Islands',
    'Puerto Rico',
    'American Samoa'))

# remove extra counties ---------------------------------------------------------

counties_cont <- 
  counties |> 
  inner_join(
    usa_cont |>
      select(state, geoid) |> 
      as_tibble(), 
    by = c('statefp' = 'geoid')) |>
  select(!geom.y) |> 
  relocate(state, .before = name)

# counties_cont <-
#   counties |>
#   st_filter(
#     usa_cont |>
#       select(state),
#     .predicate = st_intersects)

# plot terra --------------------------------------------------------------

plot(terra::vect(usa_cont))

usa_cont |> 
  ggplot() +
  geom_sf()

usa_cont |> 
  tm_shape() + 
  tm_borders() +
  tm_fill('gray90')

# save vector files -------------------------------------------------------

usa_cont |> 
  write_sf('shapefiles/processed/usa_cont.gpkg')

counties_cont |>  
  write_sf('shapefiles/processed/counties_cont.gpkg') 

# maps --------------------------------------------------------------------

# usa_cont |> 
#   tm_shape() +
#   tm_borders(col = 'white') +
#   tm_polygons('darkgreen')

# tmap_options(max.categories = 49)  

# usa_cont |>
#   mutate(name = as_factor(name)) |> 
#   tm_shape() +
#   tm_grid(lines = FALSE) +
#   tm_borders('white') +
#   tm_fill(
#     col = 'name',
#     palette = 'Set2') + 
#   tm_layout(
#     legend.outside = TRUE,
#     bg.color = 'gray80')

# tmap_options_reset()

# rasters -----------------------------------------------------------------

elevation <- 
  rast('rasters/elevation_1km.tif')

plot(elevation)

elevation_usa <-
  elevation |>
  crop(
    usa_cont,
    mask = TRUE)

plot(elevation_usa)

writeRaster(
  elevation_usa,
  'rasters/processed/elevation_usa.tif',
  overwrite = TRUE)

# maps --------------------------------------------------------------------

plot(elevation_usa)
plot(usa_cont, col = 'NA', border = 'white', add = TRUE)

plot(vect(usa_cont[usa_cont$state == 'California',]))

california <- 
  usa_cont |>
  filter(state == 'California') |>
  vect()

california_counties <-
  counties_cont |> 
  filter(state == 'California') |> 
  vect()
  
plot(crop(elevation_usa, california, mask = TRUE))
plot(california_counties, border = 'white', add = TRUE)

plot(elevation_usa)
plot(vect(usa_cont[usa_cont$state == 'California',]), add = TRUE)
plot(california_counties, border = 'white', add = TRUE)


tm_shape(world) +
  tm_polygons('gray') +
  tm_shape(
    elevation_usa |>
      crop(california, mask = TRUE),
    raster.downsample = FALSE) +
  tm_grid(lines = FALSE) +
  tm_raster(
    title = 'Elevation (m)',
    palette = terrain.colors(500),
    style = 'cont') +
  tm_shape(
    usa_cont |>
      filter(state == 'California'), is.master = T) +
  tm_borders() +
  tm_layout(
    legend.outside = TRUE,
    bg.color = 'lightblue')
  