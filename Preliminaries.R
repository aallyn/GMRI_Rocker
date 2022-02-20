#####
## Additional libraries and functions to source along with those included with the rocker/geospatial image
#####

# New as of 02/16/2022
options(timeout = 10000)
install.packages("devtools")
devtools::install_version("Matrix", version = "1.3")
install.packages("TMB")
install.packages("INLA", repos = c(getOption("repos"), INLA = "https://inla.r-inla-download.org/R/stable"), dep = TRUE, INSTALL_opts = c("--no-lock"))
library(INLA)
# install.packages("udunits2", configure.args = "--with-udunits2-include=/usr/include/udunits2")
# install.packages("units", configure.args = "--with-udunits2-include=/usr/include/udunits2")
devtools::install_github("james-thorson/FishStatsUtils", INSTALL_opts = "--no-staged-install")
devtools::install_github("james-thorson/VAST@3.7.1", INSTALL_opts = "--no-staged-install")
install.packages("splines")
# install.packages("tidyverse")
install.packages("lubridate")
install.packages("sf")
install.packages("here")
install.packages("future")
install.packages("furrr")
install.packages("targets")
install.packages("tarchetypes")
install.packages("raster")
devtools::install_github("thomasp85/patchwork")
install.packages("gifski")
install.packages("tictoc")