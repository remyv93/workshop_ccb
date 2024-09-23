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


# maps --------------------------------------------------------------------

usa |> 
  ggplot() +
  geom_sf()

counties |> 
  ggplot() +
  geom_sf()


# conterminous us ---------------------------------------------------------

# usa |> 
#   distinct(name) |> 
#   pull()

usa_cont <- 
  usa |> 
  filter(!name %in% c(
    'Hawaii', 
    'Alaska',
    'Guam',
    'Commonwealth of the Northern Mariana Islands',
    'United States Virgin Islands',
    'Puerto Rico',
    'American Samoa'))

# plot terra --------------------------------------------------------------

terra::plot(terra::vect(usa_cont))

# remove extra counties ---------------------------------------------------------

counties_cont <- 
  counties |> 
  inner_join(
    usa_cont |>
      select(state = name, geoid) |> 
      as_tibble(), 
    by = c('statefp' = 'geoid')) |>
  select(!geom.y) |> 
  relocate(state, .before = name)

# counties_cont <- 
#   counties |> 
#   st_filter(
#     usa_cont |>
#       select(state = name),
#     .predicate = st_intersects)

usa_cont |> 
  ggplot() +
  geom_sf()

counties_cont |> 
  ggplot() +
  geom_sf()

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

# elevation_usa <- 
#   elevation |> 
#   crop(
#     usa_cont, 
#     mask = TRUE)

writeRaster(
  elevation_usa,
  'rasters/elevation_usa.tif',
  overwrite = TRUE)


# maps --------------------------------------------------------------------


plot(elevation_usa)
plot(usa_cont, col = 'NA', border = 'white', add = TRUE)

plot(vect(usa_cont[usa_cont$name == 'Indiana',]))

# indiana <- usa_cont |>
#   filter(name == 'Indiana') |>
#   vect()

indiana_counties <-
  counties_cont |> 
  filter(state == 'Indiana') |> 
  vect()
  
plot(crop(elevation_usa, indiana, mask = TRUE))
plot(indiana_counties, border = 'white', add = TRUE)

plot(elevation_usa)
plot(vect(usa_cont[usa_cont$name == 'Indiana',]), add = TRUE)
plot(indiana_counties, border = 'white', add = TRUE)

# elevation_usa |>
#   # crop(indiana, mask = TRUE)
#   tm_shape(raster.downsample = FALSE) +
#   tm_grid(lines = FALSE) +
#   tm_raster(
#     title = 'Elevation (m)',
#     palette = terrain.colors(500),
#     style = 'cont') +
#   tm_shape(
#     usa_cont |>
#       filter(name == 'Indiana'), is.master = T) +
#   tm_borders() +
#   tm_layout(
#     legend.outside = TRUE,
#     bg.color = 'lightblue')
  


