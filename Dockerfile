# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:latest

# GCC issues
RUN  apt-get update \
        && apt-get install -y \
            gcc-9.2 g++-9.2 gcc-9.2-base \
        && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9.2 90 \
        && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9.2 90

# Still some things we need to add. First, make directory where we are going to have RStudio settings (and data volumes)                                             
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Github PAT
COPY ./GithubPAT.txt .Renviron

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R

# Next, some GCC work
RUN mkdir ./.R
COPY ./Makevars ./.R/Makevars