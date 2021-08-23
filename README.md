# GMRI_Rocker
This repository supports a docker container that I built (with a lot of help) to facilitate my work as a quantitative spatial ecologist. This container builds from the rocker/geospatial image generously provided by the [rocker project](https://hub.docker.com/u/rocker) by adding some additional flexibility to mount data volumes from a local machine or cloud storage to the docker container and some packages that I regulary use, especially [Jim Thorson's VAST package](https://github.com/James-Thorson-NOAA/VAST). Along with hopefully helping me, I hope it can be used by others to increase work efficiency, reproducibility and openness. 

# How did I set this up?
1. I started by creating a new repository on GitHub, called "GMRI_Rocker." I then copied the link to the repo provided by the code - clone button (repo_link).
2. On my local machine, I opened up the terminal and typed the following commands:  
`cd ~/GitHub/`  
`git clone repo_link`
3. Next, I went to work creating the necessary docker files. This was (and still is) all really new to me and I feel like I know just enough to be dangerous. I relied heavily on some nice web resources listed below and [Alex K at GMRI](https://github.com/abkfenris). Here are the files I created.  

a. A `Dockerfile`. The `Dockerfile` is basically a recipe for recreating a compute environment. I'm sure I am missing some of what it can do, but I basically think about it like a list of instructions to create an identical RStudio session as one I would run if I were to open RStudio on my local machine, along with all the necessary packages used in my analysis. For this, I started by checking out the [rocker project](https://hub.docker.com/u/rocker). There's a variety of different images available depending on your particular analysis. For example, if you are doing a lot of machine learning work, you might be more interested in the rocker/ml-verse image. For this docker container, I built from the rocker/geospatial image. With this as the base, I then added a few things. First, I copied the settings for my rstudio sessions on my local machine and added them to the container. This means that when I do open RStudio in the container, it will have the same appearance and behavior as RStudio on my local machine. Next, there were additional packages that I wanted to have installed in the docker container not included in the base image. I am sure there are other ways to do this. I decided the easiest thing was to write an .R script that had the `install` and `library` calls for what I needed. Within the dockerfile, I then instruct the container to copy the .R file inside the container and run the code.  

b. I created a `docker-compose.yaml` file and a `docker-compose.override.yaml` file. The `docker-compose.yml` file defines the services that are available within the container. In this case, rstudio. In addition, it provides a nice way to transfer data from our computer (or network) to the docker container using "volumes", which would be available for all users. For this docker image, I give an example of mounting a local data volume in the `docker-compose.yml` file (which is commented out currently). Additionally, I give an example for mounting data from a cloud based storage program with the `docker-compose.override.yml` file. The path to the cloud storage is likely going to be unique for each user and to work, each user would essentially need to edit this file. It also provides the opportunity to mount a volume for a specific project. Finally, in `docker-compose.yml` I use a `secret.env` file to load in my RStudio login and password credentials.  
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
I recently (Aug 2021) came across [Danny Foster's blog post](https://www.dfoster.science/post/r-on-digital-ocean/) about using R and it has some additional capacity that I think will be useful, particularly using Dropbox and mounted Volumes for large file management. In his workflow, Danny actually does the Digital Ocean stuff first and then the Docker stuff. I'm not sure if one way is better than the other. In any event, here is what I did to get started with Digital Ocean.  

1. First, set up an account at [Digital Ocean](https://www.digitalocean.com/) and then, if necessary, submit a ticket to request access to all of the droplet size options. 
2. Next, create a small template droplet. We can always scale up to something bigger based on this template. For this template, select the Ubuntu distribution, then a basic plan with 4GB/2 CPUs (~$24 month). Next, select add volume to the block storage and type in the GB size you will need -- I went with 300 GB. For the configuration options, the automatic formatting and mounting and Ext4 file system should be fine. Then, select a data center somewhat close to you and add the monitoring additional option. We will also want to add a new SSH Key, generated by following [Jenny Bryan's instructions](https://happygitwithr.com/ssh-keys.html). Finally, we can choose a host name and associated tags and then hit create droplet. 
3. Setting up networking. The droplet that was just created has a random IP address and we can connect to the droplet using that IP address. But, the IP address will change everytime. For example, when we go to scale things up from this small template droplet to something with more compute power. This can be a bit annoying so a floating IP address is a nice thing to have. To get the floating IP address, in the browser where we set up the droplet, hit the "Networking" tab on the left hand menu bar under "Manage". This should bring up a new page. Select the "Floating IPs" tab and then find the template droplet and assign it a floating IP address. Next, we can have this floating IP point to a domain we own by hitting the "Domains" tab. In the "Domains" manager, we can then create a new record, which will be an "A" type listing, with HOSTNAME == "your_prefix", WILL DIRECT TO = IPAddress and TTL = 60. 
4. I couldn't actually conenct to the droplet through Cyberduck (an SSH client). So, I eventually just went and copied the floating IP address of the droplet and then in a new terminal window, I typed `ssh root@floatingIPaddress`. This seemed to work and got me connected and I picked back up with Danny's instructions at the "Make sure block storage volume is mounted and attached."
5. Working with the mounted volume. To double check that the mounted volume is there, I did `cd /mnt` and then `ls`, which revealed the name of the mounted volume that Digital Ocean automatically configured for me (volume_nyc1_01). After confirming that looked good, I created a mount point for the volume and then did some things (changing fstab), which Danny recommended and I have no idea what they actually do. 
6. Setting up a non-root user. Again, this was all just following Danny's instructions. I think the general idea here is that instead of a `root` user, we can actually create named users, which should be helpful down the line with coding and file transfers. In all of the commands below, I substituted `aallyn` for `your_user`.
`root@your_domain:~# adduser --system --group your_user`  

`root@your_domain:~# usermod -u 1000 your_user` 

`root@your_domain:~# mkdir /home/your_user/.ssh`  

`root@your_domain:~# chmod 0700 /home/your_user/.ssh/`  

`root@your_domain:~# cp -Rfv /root/.ssh /home/your_user/`  

`root@your_domain:~# chown -Rfv your_user.your_user /home/your_user/.ssh`  

`root@your_domain:~# chown -R your_user:your_user /home/your_user/`  

`root@your_domain:~# chown -R your_user:your_user /mnt/volume_nyc1_01/`  

`root@your_domain:~# gpasswd -a your_user sudo`  

`root@your_domain:~# echo "your_user ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)`  

`root@your_domain:~# service ssh restart`  

`root@your_domain:~# usermod -s /bin/bash your_user`  

`root@your_domain:~# usermod -a -G docker your_user`  

`logout`  

If for some reason you get an errror that docker is not a recognized group when running the second to last line, you can do  
`sudo groupadd docker`
and then  
`usermod -a -G docker your_user`.

7. Setting up SSL certificates. I skipped this part for now as I am not sure if the domain I was using (aallyn.github.io) is really considered an acceptable domain and the issues I had in step 4 above.

8. Installing docker. In terminal, I checked that I was still in the right directory, which is the one for this docker container. Then In terminal, I typed `ssh your_user@IPaddressoftheDigitalOceanDroplet`  
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
  
  9. Docker time!

- I then git cloned the repo
- Next cd into the docker repo
- Next create your secret.env file using nano
- Do the same with GithubPAT.txt
  
  After completing those interim steps, I returned to the above workflow for the `make up` call. Then, to access the container on the DigitalOcean droplet, I opened a web broswer to web "http://IPaddressoftheDigitalOceanDroplet:8787" as opposed to "http://localhost:8787". I then worked as I outlined above, while adding one additional step to shut down the droplet when I was finished with it.  

  10. Next, we need to make sure we have access to the mounted volume storage. To do this, we edit the `docker-compose.yaml` file with the following lines to the "volumes" portion
      `- $HOME/:/home/aallyn/`
      `- /mnt/volume_nyc1_01/:/home/aallyn/block_storage/`
  

  11. Dropbox all the same except for adding 
  `sudo apt install libc6 libglapi-mesa libxdamage1 libxfixes3 libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1` before running the phython3 command.

  12. 

# Other helpful resources #
For more help, check out:  
- Jenny Bryan (Git/GitHub and R): https://happygitwithr.com/  
- Andrew Heiss (R, DigitalOcean, and R's "future" package): https://www.andrewheiss.com/blog/2018/07/30/disposable-supercomputer-future/  
- Andrew Heiss (Docker, RStudio and DigitalOcean): https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/  
- Derek Powell (Docker, Git/GitHub and Docker Hub): http://www.derekmpowell.com/posts/2018/02/docker-tutorial-2/  
- Joel Nitta (https://www.joelnitta.com/post/how-to-run-an-r-analysis-anywhere/how-to-run-an-r-analysis-anywhere/)  
- Brian Hogan (https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) 
