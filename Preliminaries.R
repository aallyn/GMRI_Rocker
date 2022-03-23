#####
## Additional libraries and functions to source along with those included with the rocker/geospatial image
#####

# New as of 02/16/2022
options(timeout = 10000)
install.packages("devtools")
devtools::install_version("Matrix", version = "1.4")
install.packages("TMB")
library(TMB)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(c("graph", "Rgraphviz"), dep=TRUE)
install.packages("INLA", repos = c(getOption("repos"), INLA = "https://inla.r-inla-download.org/R/stable"), dep = TRUE)
library(INLA)
devtools::install_github("james-thorson/FishStatsUtils@2.10.2", dep = TRUE, INSTALL_opts = "--no-staged-install")
devtools::install_github("james-thorson/VAST@3.8.2", dep = TRUE, INSTALL_opts = "--no-staged-install")
devtools::install_github("thomasp85/patchwork")
