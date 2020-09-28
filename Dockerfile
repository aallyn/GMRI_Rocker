# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:latest

# GCC issues
RUN sed -i 's/# deb-src/deb-src/' /etc/apt/sources.list
RUN wget http://mirrors.concertpass.com/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz
RUN tar xvf gcc-9.2.0.tar.gz
RUN cd gcc-9.2.0
RUN apt build-dep gcc
RUN ./contrib/download_prerequisites
RUN cd ..
RUN mkdir objdir
RUN cd objdir
RUN $PWD/../gcc-9.2.0/configure --prefix=/usr/bin/gcc-9.2 --enable-languages=c,c++,fortran,go --disable-multilib
RUN make -j 8
RUN make install
RUN cd .

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