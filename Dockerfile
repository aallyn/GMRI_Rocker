# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:latest

# Still some things we need to add. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R

# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R