# GMRI_Rocker
**Update February 2023**
This repository supports a docker container that I built (with a lot of help) to facilitate my work as a quantitative spatial ecologist. This container builds from the rocker/geospatial image generously provided by the [rocker project](https://hub.docker.com/u/rocker) by adding some additional flexibility to use some packages that I regulary use, especially [Jim Thorson's VAST package](https://github.com/James-Thorson-NOAA/VAST). Along with hopefully helping me, I hope it can be used by others to increase work efficiency, reproducibility and openness. 

Although you could certainly launch the Docker container locally, one of the biggest reasons for going through this process is to get a docker container that can be opened and used by cloud computing services. I have been back and forth with different options for doing that and it has been a bit dizzying. Ultimately, I am going to try to make things work using Google Cloud Computing resources as I already use google drive regularly for file storage and this *seems* like the easiest path. For more information on the cloud computing side, [please see the related Cloud_Computing repository](https://github.com/aallyn/Cloud_Computing)

# Setting up a Docker container 
1. I created a new repository on GitHub, called "GMRI_Rocker." I then copied the link to the repo provided by the code - clone button and then used Fork to clone the repository to my local machine. There are plenty of other options for doing this (e.g, through R studio or using the terminal and `git clone repo_link`).

2. Next, I went to work creating the necessary Docker files. This was (and still is) all really new to me and I feel like I know just enough to be dangerous. I relied heavily on some nice web resources listed below and [Alex K at GMRI](https://github.com/abkfenris). Here are the files I created:  

a. A `Dockerfile`. The `Dockerfile` is a recipe for recreating a compute environment. I'm sure I am missing some of what it can do, but I basically think about it as a list of instructions to create an identical RStudio session to the one that starts on my local machine, particularly all the necessary packages used in my analysis. For this, I started by checking out the [rocker project](https://hub.docker.com/u/rocker). There's a variety of different images available depending on your particular analysis. For example, if you are doing a lot of machine learning work, you might be more interested in the rocker/ml-verse image. For this Docker container, I built from the rocker/geospatial image. With this as the base, I then added a few things. First, I copied the settings for my Rstudio sessions on my local machine and added them to the container (*don't think that actually worked?*). This means that when I do run the container, it will have the same appearance and behavior as RStudio on my local machine. Next, there were additional packages that I wanted to have installed in the Docker container that were not included in the base image. I am sure there are other ways to do this. I decided the easiest thing was to do a combination using `RUN install2.r` within the `Dockerfile` and then also writing an R script that had the `install` and `library` calls for what I needed, which is the `Preliminaries.R` script. Within the `Dockerfile`, I then instructed the container to copy the R file inside the container and source the code. 

b. I created a `docker-compose.yaml` file and a `docker-compose.override.yaml` file. The `docker-compose.yaml` file defines the services that are available within the container. In this case, rstudio. **To do: Passing secret.env, GitHub and Google authorization information?

c. Next, I created a `Makefile`. My general understanding is the Makefile provides an easy way of capturing a lot of the commands you might enter in the terminal to start up and shut down the Docker container. After creating this file, things are a bit easier as I only need to enter `make up` in the terminal and then `make down`.  
d. Finally, I created a `.gitignore` file. This can include a number of different things. Here, I used it mainly to make sure my `secret.env` file with user name and password are not stored on GitHub.  

4. After creating the above files, I went ahead and stage, commited and pushed them to the GitHub repo. I also did this whenever I needed to make any changes to the docker files.  
`git add .`  
`git commit -m "Initial commit"`  
`git push origin master`  
I think there is a way that you could then link this up to DockerHub so that in the future any changes to the repo would prompt an automatic build. This was causing me issues. So, I aborted that approach. But, it is definitely a potential option. 

If you still want to make sure things are on Dockerhub, you can go through a process where you create a new repo on Dockerhub. You can then type the following lines in the terminal to build, tag, and push this docker container to your Dockerhub account. For me, I typed 
`docker build .` followed by `docker tag HASHOFBUILD dockerhubrepoaccountname/dockerhubtargetrepo:tag name` and finally `docker push dockerhubrepoaccountname/dockerhubtargetrepo:tag name`.

5. Now that everything was stored on GitHub and ready to go, I was ready to compose, build and run the container. Given the earlier work with the `Makefile`, this process was really easy. In the terminal, I made sure I was in the correct directory and then typed  
`make up`  
The first time calling `make up`, it took a little while as the Docker container was built, according to the recipe in the `Dockerfile` and any adjustments from the `docker-compose.yml` or `docker-compose.override.yml` files. When it is done, you will likely see something like  
`rstudio-1 | [services.d] done.` in the terminal window.  
With that, I opened a web browser and typed "http://localhost:8787", which opened an RStudio instance in the web browser, a carbon copy of the one I have if I opened the RStudio app on my local machine!

6. Next, I went to work just like I would normally. When I was done for the day, I stage, committed and pushed my changes from Docker container to GitHub online.

10. Finally, with the work done, I stopped and removed the container by typing in the terminal  
`ctrl + c`  
`make down` 

## Things to consider 
- Docker compose things: user and password information, most efficient way to move data (local, Box, googledrive, etc)
- Best practice for getting project code from GitHub repo -- mount? git clone as part of the docker build. For now, I have just mounted the local GitHub repo folder. I have done this another way. To get the code bits and small files, I went to my GitHub account online and copied the address of the repo that has the code/data/etc (analysis_repo_link) I wanted to bring in the container. Back in the RStudio instance on the web browser, I started a new project, selected version controlled, Git, and then pasted the address for the repo I had just copied. I then opened up a terminal window and typed the following to make the full connection to the GitHub repo and pull in its contents
`git init`  
`git remote add origin analysis_repo_link`  

* This should return that the remote already exists if I did the above step correctly.  
`git config --global user.name "Your github user name"`  
`git config --global user.email "Your github email"`  
`git config --global user.password "yourtoken"`  
`git pull origin main`  
* This should return a message that things are already up to date

# Looking ahead
Now that we have the Docker container running and are able to create "images" with the compute environment we want, the next step towards really leveraging this benefit is moving our analysis to the cloud. For more on that, have a look at a related repository [Cloud_Computing repository](https://github.com/aallyn/Cloud_Computing)

# Issues or questions?
If anyone actually ends up using this and running into issues or has any feedback to give, [just reach out](mailto:andrew.allyn@gmail.com) -- always interested in chatting! 

# Other helpful resources
For more help, check out:  
- Jenny Bryan (Git/GitHub and R): https://happygitwithr.com/  
- Andrew Heiss (R, DigitalOcean, and R's "future" package): https://www.andrewheiss.com/blog/2018/07/30/disposable-supercomputer-future/  
- Andrew Heiss (Docker, RStudio and DigitalOcean): https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/  
- Derek Powell (Docker, Git/GitHub and Docker Hub): http://www.derekmpowell.com/posts/2018/02/docker-tutorial-2/  
