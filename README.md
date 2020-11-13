# GMRI_Rocker
This repository supports a docker container that I built (with a lot of help) to facilitate my work as a quantitative spatial ecologist. This container builds from the rocker/geospatial image generously provided by the [rocker project](https://hub.docker.com/u/rocker) by adding some additional flexibility to mount data volumes from a local machine or cloud storage to the docker container and some packages that I regulary use, especially [Jim Thorson's VAST package](https://github.com/James-Thorson-NOAA/VAST). Along with hopefully helping me, I hope it can be used by others to increase work efficiency, reproducibility and openness. 

# How did I set this up?
1. I started by creating a new repository on GitHub, called "GMRI_Rocker." I then copied the link to the repo provided by the code - clone button (repo_link).
2. On my local machine, I opened up the terminal and typed the following commands:  
`cd ~/GitHub/`  
`git clone repo_link`
3. Next, I went to work creating the necessary docker files. This is all really new to me and I feel like I know just enough to be dangerous. I relied heavily on some nice web resources listed below and [Alex K at GMRI](https://github.com/abkfenris). Here are the files I created.  
a. A `Dockerfile`. The `Dockerfile` is basically a recipe for recreating a compute environment. I'm sure I am missing some of what it can do, but I basically think about it like a list of instructions to create an identical RStudio session as one I would run if I were to open RStudio on my local machine, along with all the necessary packages used in my analysis. For this, I started by checking out the [rocker project](https://hub.docker.com/u/rocker). There's a variety of different images available depending on your particular analysis. For example, if you are doing a lot of machine learning work, you might be more interested in the rocker/ml-verse image. For this docker container, I built from the rocker/geospatial image. With this as the base, I then added a few things. First, I copied the settings for my rstudio sessions on my local machine and added them to the container. This means that when I do open RStudio in the container, it will have the same appearance and behavior as RStudio on my local machine. Next, there were additional packages that I wanted to have installed in the docker container not included in the base image. I am sure there are other ways to do this. I decided the easiest thing was to write an .R script that had the `install` and `library` calls for what I needed. Within the dockerfile, I then instruct the container to copy the .R file inside the container and run the code.  
b. I created a `docker-compose.yml` file and a `docker-compose.override.yml` file. The `docker-compose.yml` file defines the services that are available within the container. In this case, rstudio. In addition, it provides a nice way to transfer data from our computer (or network) to the docker container using "volumes", which would be available for all users. For this docker image, I give an example of mounting a local data volume in the `docker-compose.yml` file (which is commented out currently). Additionally, I give an example for mounting data from a cloud based storage program with the `docker-compose.override.yml` file. The path to the cloud storage is likely going to be unique for each user and to work, each user would essentially need to edit this file. It also provides the opportunity to mount a volume for a specific project. Finally, in `docker-compose.yml` I use a `secret.env` file to load in my RStudio login and password credentials.  
c. Next, I created a `Makefile`. My general understanding is the Makefile provides an easy way of capturing a lot of the commands you might enter in the terminal to start up and shut down the docker container. After creating this file, things are a bit easier as I only need to enter `make up` in the terminal and then `make down`.  
d. Finally, I created a `.gitignore` file. This can include a number of different things. Here, I used it mainly to make sure my `secret.env` file with user name and password are not stored on GitHub. 
4. After creating the above files, I went ahead and stage, commited and pushed them to the GitHub repo. I also did this whenever I needed to make any changes to the docker files.  
`git add .`  
`git commit -m "Initial commit"`  
`git push origin master`  
I think there is a way that you could then link this up to DockerHub so that in the future any changes to the repo would prompt an automatic build. This was causing me issues. So, I aborted that approach. But, it is definitely a potential option. 
5. Now that everything was stored on GitHub and ready to go, I was ready to compose, build and run the container. Give the earlier work with the `Makefile`, this process was really easy. In the terminal, I made sure I was in the correct directory and then just typed  
`make up`  
The first time calling `make up`, it took a little while as the docker container was built, according to the recipe in the `Dockerfile` and any adjustments from the `docker-compose.yml` or `docker-compose.override.yml` files. When it is done, you will likely see something like  
`rstudio-1 | [services.d] done.` in the terminal window.  
With that, I opened a web browser and typed "http://localhost:8787", which opened an RStudio instance in the web browser, a carbon copy of the one I have if I opened the RStudio app on my local machine.
8.  After getting the computing environmnet set up, the next thing I needed was to get my code and data into the container. For the code bits and small files, I used GitHub. For larger files, I use the volume approach discused earlier. To get the code bits and small files, I went to my GitHub account online and copied the address of the repo that has the code/data/etc (analysis_repo_link) I wanted to bring in the container. Back in the RStudio instance on the web browser, I started a new project, selected version controlled, Git, and then pasted the address for the repo I had just copied. I then opened up a terminal window and typed the following to make the full connection to the GitHub repo and pull in its contents  
`git remote add origin analysis_repo_link`  
* This should return that the remote already exists if I did the above step correctly.  
`git config --global user.name "Your github user name"`  
`git config --global user.email "Your github email"`  
`git config --global user.password "Your github password"`  
`git pull origin master`  
* This should return a message that things are already up to date
9. Next, I went to work  just like I would normally do! When I was done for the day, I stage, committed and pushed my changes from docker container to GitHub online.
10. Finally, with the work done, I stopped and removed the container by typing in the terminal  
`ctrl + c`  
`make down` 

# Working with Digital Ocean
The above steps work great for using my local machine. Though, there is some additional work when it comes to trying to use the container on a remote server, like DigitalOcean. For that, I substituted in the following steps between steps 4 and 5 above. 

Generate a new public key on your local machine and copy it (https://dev.to/gamebusterz/digitalocean-permission-denied-publickey-168p)

5b. Set up DigitalOcean account and specify a new droplet  
- Go to https://www.digitalocean.com/  
- Set up a new account if necessary and then submit a ticket to request access to all of the droplet options (some of these are likely greyed out until you do this)  - Copy over your key
- Create a new project 
- Deploy a new droplet within the new project, use the Ubuntu option and select the ssh key you copied over
- Copy droplet IP address  

6b. Install docker on the DigitalOcean droplet  
- In terminal, I checked that I was still in the right directory, which is the one for this docker container.  
- In terminal, I typed `ssh root@IPaddressoftheDigitalOceanDroplet`  
- In terminal, I then ran the following to install docker on the DigitalOcean droplet
  + `sudo apt update`  
  + `sudo apt install apt-transport-https ca-certificates curl software-properties-common`  
  + `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`  
  + `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"` 
  + `sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`
  + `sudo chmod +x /usr/local/bin/docker-compose`
  + `sudo apt update`  
  + `apt-cache policy docker-ce`  
  + `sudo apt install docker-ce` 
  + `sudo apt install make` 
  + `sudo apt install mtools` 

- I then git cloned the repo
- Next cd into the docker repo
- Next create your secret.env file using nano
- Do the same with GithubPAT.txt
  
  After completing those interim steps, I returned to the above workflow for the `make up` call. Then, to access the container on the DigitalOcean droplet, I opened a web broswer to web "http://IPaddressoftheDigitalOceanDroplet:8787" as opposed to "http://localhost:8787". I then worked as I outlined above, while adding one additional step to shut down the droplet when I was finished with it.  

# Other helpful resources #
For more help, check out:  
- Jenny Bryan (Git/GitHub and R): https://happygitwithr.com/  
- Andrew Heiss (R, DigitalOcean, and R's "future" package): https://www.andrewheiss.com/blog/2018/07/30/disposable-supercomputer-future/  
- Andrew Heiss (Docker, RStudio and DigitalOcean): https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/  
- Derek Powell (Docker, Git/GitHub and Docker Hub): http://www.derekmpowell.com/posts/2018/02/docker-tutorial-2/  
- Joel Nitta (https://www.joelnitta.com/post/how-to-run-an-r-analysis-anywhere/how-to-run-an-r-analysis-anywhere/)  
- Brian Hogan (https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) 
