# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:latest

# GCC issues
RUN apt-get g++-9.2.0

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