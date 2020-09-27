#####
## Additional libraries and functions to source along with those included with the rocker/geospatial image
#####

install.packages("devtools")
require(devtools)

install.packages("Matrix")
require(Matrix)

install.packages("TMB")
require(TMB)

install_github("james-thorson/FishStatsUtils", INSTALL_opts="--no-staged-install")
require(FishStatsUtils)

install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
require(INLA)

install_github("james-thorson/VAST", ref = "3.5.0")
require(VAST)

install.packages("here")
require(here)

install_github("ropensci/rnaturalearthdata")
require(rnaturalearthdata)

install_github("thomasp85/patchwork")
require(patchwork)

install_github("HenrikBengtsson/future.apply@1.3.0")
require(future.apply)

install.packages("googledrive")
require(googledrive)

install.packages("snakecase")
require(snakecase)

install.packages("parallel")
require(parallel)

install.packages("dopParallel")
require(parallel)