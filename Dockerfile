# Loading rclone stuff first
FROM rclone/rclone as rclone-source

# Load base image, in this case the geospatial image from Rocker
FROM rocker/tidyverse:4.1.2

COPY --from=rclone-source /usr/local/bin/rclone /usr/local/bin/rclone

# Still some things we need to add. First, make directory where we are going to have RStudio settings (and data volumes)                                             
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Github PAT
COPY ./GithubPAT.txt ./GithubPAT.txt
COPY ./GithubPAT.txt .Renviron
COPY ./secret.env ./secret.env

# Copy Makevars
RUN mkdir .R \
    && echo 'CXX = g++ -fno-gnu-unique' > .R/Makevars

# Udunits 
RUN apt-get install -y libudunits2-dev

# Install DVC
RUN apt-get update \
    && apt-get install -y python \
    && apt-get install -y python3-pip

RUN pip install DVC \
    && pip install dvc[gdrive]

# Github...
ARG GIT_TOKEN
RUN git init \
    && git clone https://GIT_TOKEN@github.com/aallyn/TargetsSDM.git /home/aallyn/TargetsSDM

# TMB
# RUN git clone https://github.com/kaskr/adcomp /home/aallyn/adcomp 
# WORKDIR /home/aallyn/adcomp
# RUN make install-metis-full
# WORKDIR /home/aallyn

# Change directory and DVC pull -- doesn't work. Do this manually inside the container on the Droplet.
# WORKDIR /home/aallyn/TargetsSDM
# RUN dvc pull

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R



