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

install_github("james-thorson/VAST", INSTALL_opts="--no-staged-install")
require(VAST)
