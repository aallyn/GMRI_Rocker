# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:4.2.1

# R add ons (following https://cloudyr.github.io/googleComputeEngineR/articles/docker.html)
RUN apt-get update \
    && apt-get install -y \
    libssl-dev \
    ## clean up
    && apt-get clean \ 
    && rm -rf /var/lib/apt/lists/ \ 
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Install packages from CRAN
RUN install2.r --error \
    remotes \
    googleAuthR 
 
# RStudio settings                                 
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R