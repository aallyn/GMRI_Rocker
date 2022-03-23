# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:4.1.2

# R add ons that can be installed easily
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends \
#     libudunits2-dev \
#     # libgdal-dev \
#     # libgeos-dev \
#     libxml2-dev \
#     libcurl4-openssl-dev \
#     libssl-dev

RUN install2.r --error \
    devtools \
    # rgdal \
    # sf \
    # sp \
    # rgeos \
    # raster \
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

# RStudio settings                                 
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Github stuffs
COPY ./secret.env ./secret.env

# Install DVC
RUN apt-get update \
    && apt-get install -y python \
    && apt-get install -y python3-pip

# Configuring DVC
RUN pip install DVC \
    && pip install dvc[gdrive]

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R

# Project specific stuff -- likely move out to its own VAST docker image?
# Github for this specific project
RUN git init \
    && git clone https://github.com/aallyn/TargetsSDM.git /home/aallyn/TargetsSDM

# DVC bits
WORKDIR /home/aallyn/TargetsSDM
# RUN dvc remote modify google-drive gdrive_use_service_account  \
#     && dvc remote modify google-drive --local gdrive_use_service_account ${GOOGLE_APPLICATION_CREDENTIALS} \
#     && dvc pull
