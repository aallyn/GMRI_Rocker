# Load base image, in this case the geospatial image from Rocker
FROM rocker/geospatial:3.6.2

# GCC issues
#RUN wget https://mirrors.concertpass.com/gcc/releases/gcc-9.2.0/gcc-9.2.0.tar.gz
#RUN tar xvf gcc-9.2.0.tar.gz
#RUN cd gcc-9.2.0
#RUN ./contrib/download_prerequisites
#RUN cd ..
#RUN mkdir gcc-build
#RUN cd gcc-build
#RUN ../gcc-9.2.0/configure -v --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --prefix=/usr/local/gcc-9.2 --enable-checking=release --enable-languages=c,c++,fortran --disable-multilib --program-suffix=-9.2
#RUN make -j 2
#RUN make install

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