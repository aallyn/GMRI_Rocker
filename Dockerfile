# Loading rclone stuff first
FROM rclone/rclone as rclone-source

# Load base image, in this case the geospatial image from Rocker
FROM rocker/tidyverse:4.1.2

ARG GITHUB_PAT
ARG GIT_TOKEN

# R add ons that can be installed easily
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev

RUN install2.r --error \
    devtools \
    rgdal \
    sf \
    sp \
    rgeos \
    raster \
    TMB \
    splines \
    here \
    future \
    furrr \
    targets \
    tarchetypes \
    lubridate \
    gifski \
    tictoc

COPY --from=rclone-source /usr/local/bin/rclone /usr/local/bin/rclone

# Still some things we need to add. First, make directory where we are going to have RStudio settings (and data volumes)                                             
# COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Github stuffs
COPY ./secret.env ./secret.env
RUN git config --global credential.helper \
    '!f() { echo username=$GITHUB_username; echo "password=$GIT_TOKEN"; };f'

# Install DVC
RUN apt-get update \
    && apt-get install -y python \
    && apt-get install -y python3-pip

RUN pip install DVC \
    && pip install dvc[gdrive]

# Github for this specific project
RUN git init \
    && git clone https://GIT_TOKEN@github.com/aallyn/TargetsSDM.git /home/aallyn/TargetsSDM

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R



