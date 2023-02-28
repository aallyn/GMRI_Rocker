#####
## Additional libraries and functions to source along with those included with the rocker/geospatial image
#####

# New as of 2023-02-27
library(TMB)
remotes::install_github("james-thorson/VAST", ref = "ae94aaa81db4996e4355ded1e947d33c2140f0c8" dep = TRUE")
