# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:4.0.2

# Still some things we need to add. First, make directory where we are going to have RStudio settings (and data volumes)                                             
COPY ./rstudio-prefs.json /etc/rstudio/rstudio-prefs.json

# Github PAT
COPY ./GithubPAT.txt .Renviron

# Next, additional libraries or functions. Seemed easiest to do this using an R script. Need to copy the script over into our docker container.
COPY ./Preliminaries.R ./Preliminaries.R
COPY ./vast_functions.R ./vast_functions.R
# Now that we have copied it over, we can run it
RUN Rscript Preliminaries.R
RUN Rscript vast_functions.R

# Copy Makevars
RUN mkdir .R
COPY ./Makevars .R/Makevars

# Start dropbox
#RUN echo "python3 /mnt/volume_nyc1_01/dropbox.py start"