# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:4.0.2

# SUDOER
RUN apt-get update && \
      apt-get -y install sudo

RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

USER docker
CMD /bin/bash

# Still some things we need to add. First, make directory where we are going to have RStudio settings (and data volumes)                                             
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Github PAT
COPY ./GithubPAT.txt .Renviron

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R

# Copy Makevars
RUN mkdir .R
COPY ./Makevars .R/Makevars