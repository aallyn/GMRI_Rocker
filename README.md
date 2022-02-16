# GMRI_Rocker
This repository supports a docker container that I built (with a lot of help) to facilitate my work as a quantitative spatial ecologist. This container builds from the rocker/geospatial image generously provided by the [rocker project](https://hub.docker.com/u/rocker) by adding some additional flexibility to mount data volumes from a local machine or cloud storage to the docker container and some packages that I regulary use, especially [Jim Thorson's VAST package](https://github.com/James-Thorson-NOAA/VAST). Along with hopefully helping me, I hope it can be used by others to increase work efficiency, reproducibility and openness. 

Along with the docker information, the other piece of this repo relates to using the docker container on Digital Ocean to leverage cloud computing resources. I'm not sure if there is a correct order or not -- some folks do the Digital Ocean bits first and then the Docker work, while others do the opposite. Given how useful Docker is without needing Digital Ocean, I walk through the Docker instructions first. 

# Setting up a docker container repository
1. I started by creating a new repository on GitHub, called "GMRI_Rocker." I then copied the link to the repo provided by the code - clone button (repo_link).

2. On my local machine, I opened up the terminal and typed the following commands:  
`cd ~/GitHub/`  
`git clone repo_link`

3. Next, I went to work creating the necessary docker files. This was (and still is) all really new to me and I feel like I know just enough to be dangerous. I relied heavily on some nice web resources listed below and [Alex K at GMRI](https://github.com/abkfenris). Here are the files I created.  

a. A `Dockerfile`. The `Dockerfile` is a recipe for recreating a compute environment. I'm sure I am missing some of what it can do, but I basically think about it like a list of instructions to create an identical RStudio session to the one that starts on my local machine if I open RStudio, along with all the necessary packages used in my analysis. For this, I started by checking out the [rocker project](https://hub.docker.com/u/rocker). There's a variety of different images available depending on your particular analysis. For example, if you are doing a lot of machine learning work, you might be more interested in the rocker/ml-verse image. For this docker container, I built from the rocker/geospatial image. With this as the base, I then added a few things. First, I copied the settings for my rstudio sessions on my local machine and added them to the container. This means that when I do open RStudio in the container, it will have the same appearance and behavior as RStudio on my local machine. Next, there were additional packages that I wanted to have installed in the docker container not included in the base image. I am sure there are other ways to do this. I decided the easiest thing was to write an .R script that had the `install` and `library` calls for what I needed. Within the dockerfile, I then instruct the container to copy the .R file inside the container and run the code.  

**Note as of Fall 2021** I was really running into some issues with moving data into and out of the container when it was eventually run on a DigitalOcean droplet. I tried a bunch of different stuff (e.g., mounting a volume storage to Dropbox) and nothing seemed to work. As a last attempt, I tried out the `Rclone` copy and sync functionality. This meant adding this into the docker image and the `Dockerfile` now reflects this with essentially two `FROM` statements.

b. I created a `docker-compose.yaml` file and a `docker-compose.override.yaml` file. The `docker-compose.yaml` file defines the services that are available within the container. In this case, rstudio. In addition, it provides a nice way to transfer data from our computer (or network) to the docker container using "volumes", which would be available for all users. For this docker image, I give an example of mounting a local data volume in the `docker-compose.yaml` file (which is commented out currently). Additionally, I give an example for mounting data from a cloud based storage program with the `docker-compose.override.yaml` file. The path to the cloud storage is likely going to be unique for each user and to work, each user would essentially need to edit this file. It also provides the opportunity to mount a volume for a specific project. Finally, in `docker-compose.yaml` I use a `secret.env` file to load in my RStudio login and password credentials.  

c. Next, I created a `Makefile`. My general understanding is the Makefile provides an easy way of capturing a lot of the commands you might enter in the terminal to start up and shut down the docker container. After creating this file, things are a bit easier as I only need to enter `make up` in the terminal and then `make down`.  
d. Finally, I created a `.gitignore` file. This can include a number of different things. Here, I used it mainly to make sure my `secret.env` file with user name and password are not stored on GitHub.  

4. After creating the above files, I went ahead and stage, commited and pushed them to the GitHub repo. I also did this whenever I needed to make any changes to the docker files.  
`git add .`  
`git commit -m "Initial commit"`  
`git push origin master`  
I think there is a way that you could then link this up to DockerHub so that in the future any changes to the repo would prompt an automatic build. This was causing me issues. So, I aborted that approach. But, it is definitely a potential option. 

If you still want to make sure things are on Dockerhub, you can go through a process where you create a new repo on Dockerhub. You can then type the following lines in the terminal to build, tag, and push this docker container to your Dockerhub account. This becomes helpful later on if you move to working on Digital Ocean. For me, I typed 
`docker build .` followed by `docker tag HASHOFBUILD dockerhubrepoaccountname/dockerhubtargetrepo:tag name` and finally `docker push dockerhubrepoaccountname/dockerhubtargetrepo:tag name`.

5. Now that everything was stored on GitHub and ready to go, I was ready to compose, build and run the container. Given the earlier work with the `Makefile`, this process was really easy. In the terminal, I made sure I was in the correct directory and then just typed  
`make up`  
The first time calling `make up`, it took a little while as the docker container was built, according to the recipe in the `Dockerfile` and any adjustments from the `docker-compose.yml` or `docker-compose.override.yml` files. When it is done, you will likely see something like  
`rstudio-1 | [services.d] done.` in the terminal window.  
With that, I opened a web browser and typed "http://localhost:8787", which opened an RStudio instance in the web browser, a carbon copy of the one I have if I opened the RStudio app on my local machine.

6. After connecting to the local RStudio instance running inside the docker container, I start to work to more easily move files between local computer/docker container/droplet and google drive. To do this, I followed the instructions here post build: https://rclone.org/drive/, with one exception. When prompted to say yes or no, I selected no as I was in a remote/headless situation running RStudio on the local host. 

8.  After getting the computing environmnet set up, the next thing I needed was to get my code and data into the container. For the code bits and small files, I used GitHub. For larger files, I use the volume approach discused earlier. To get the code bits and small files, I went to my GitHub account online and copied the address of the repo that has the code/data/etc (analysis_repo_link) I wanted to bring in the container. Back in the RStudio instance on the web browser, I started a new project, selected version controlled, Git, and then pasted the address for the repo I had just copied. I then opened up a terminal window and typed the following to make the full connection to the GitHub repo and pull in its contents
`git init`  
`git remote add origin analysis_repo_link`  

* This should return that the remote already exists if I did the above step correctly.  
`git config --global user.name "Your github user name"`  
`git config --global user.email "Your github email"`  
`git config --global user.password "yourtoken"`  
`git pull origin main`  
* This should return a message that things are already up to date

To confirm this all worked, I then typed `rclone lsd your_remote_name:` and was relieved to see all of the google drive folders listed. To get these files into the docker container, I ran the following two commands:

`mkdir /home/aallyn/destination_folder_name`
`rclone sync "your_remote_name:your_remote_folder_path" "/home/aallyn/destination_folder_name"`

This took a little time, but eventually I could see I had all of the folders/files I needed! I also wrote out a simple .csv file from R and then did the following to see if the file was copied to google drive, and it was!
`rclone copy --update "/home/aallyn/destination_folder_name/testing.csv" "your_remote_name:your_remote_folder_path/testing.csv"`

9. Next, I went to work  just like I would normally do! When I was done for the day, I stage, committed and pushed my changes from docker container to GitHub online.

10. Finally, with the work done, I stopped and removed the container by typing in the terminal  
`ctrl + c`  
`make down` 



# Working with Digital Ocean
I recently (Aug 2021) came across [Danny Foster's blog post](https://www.dfoster.science/post/r-on-digital-ocean/) about using R/Docker and Digital Ocean. It has some additional capacity that I thought would be useful, particularly using Dropbox and mounted Volumes for large file management. In his workflow, Danny actually does the Digital Ocean stuff first and then the Docker stuff. I'm not sure if one way is better than the other. In any event, here is what I did to get started with Digital Ocean, which largely follows Danny's recommendations. 

1. The first thing I did was set up an account at [Digital Ocean](https://www.digitalocean.com/). When I did that, I had a bunch of resources that weren't available to me. To get access, I had to submit a ticket to request access to all of the droplet size options.  

2. Next, I created a small template droplet. As Danny mentions in his instructions, we can always scale up to something bigger based on this template and the template provides a nice "snapshot" to start from. In a lot of ways, this is similar to how docker works, where instead of constantly building from a bare-bones image, we can make a new image with our additions and then start from there. For the basic template, I selected the Ubuntu distribution, then a basic plan with 4GB/2 CPUs (~$24 month). Next, I added volume to the block storage and typed in the GB size I thought I would need -- I went with 300 GB. A quick aside here, this volume of block storage is where I eventually sync up a specific Dopbows folder. For the configuration options,I went with the automatic formatting and mounting and Ext4 file system. Then, I selected a NYC data center and added the monitoring additional option. Finally, I added a new SSH key following [Jenny Bryan's instructions](https://happygitwithr.com/ssh-keys.html) and chose a host name and associated tags. In Danny's work, this host name becomes important as it connects to a specific domain. I didn't end up getting that working, though will likely try to do something similar later on.  

3. After creating the droplet, I went to Danny's next step of setting up networking. Again, here things were a bit different for me as I didn't go through the whole domain set up part. That said, I did work through setting up a floating IP address. This is helpful because it keeps the IP address the same each time a new droplet is created from this snapshot. To get the floating IP address, in the browser where I set up the droplet, I hit the "Networking" tab on the left hand menu bar under "Manage." This brought open a new browser page, where I selected the "Floating IPs" tab. I then highlighted the template droplet and assigned it a floating IP address. 

4. Once this was done, I connected to the droplet through the terminal and using the `ssh` command. Here is another spot where things were a bit different for me. Instead of ssh'ing to a specific domain, I just typed `ssh root@floatingIPaddress`. This seemed to work and got me connected to the droplet. I then picked back up with Danny's instructions at the "Make sure block storage volume is mounted and attached." section.

6. Next, I set up a non-root user. I think the general idea here is that instead of having things start at `root`, you can actually create named users, which will likely be helpful down the line with executing code, writing code, etc. I followed Danny's instructions exactly and ran the following lines, while substituting "aallyn" for "your user".

`root@your_domain:~# adduser --system --group aallyn`  

`root@your_domain:~# usermod -u 1000 aallyn` 

`root@your_domain:~# mkdir /home/aallyn/.ssh`  

`root@your_domain:~# chmod 0700 /home/aallyn/.ssh/`  

`root@your_domain:~# cp -Rfv /root/.ssh /home/aallyn/`  

`root@your_domain:~# chown -Rfv aallyn.aallyn /home/aallyn/.ssh`  

`root@your_domain:~# chown -R aallyn:aallyn /home/aallyn/`  

`root@your_domain:~# chown -R aallyn:aallyn /mnt/volume_nyc1_01/`  

`root@your_domain:~# gpasswd -a aallyn sudo`  

`root@your_domain:~# echo "aallyn ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)`  

`root@your_domain:~# service ssh restart`  

`root@your_domain:~# usermod -s /bin/bash aallyn`  

`root@your_domain:~# usermod -a -G docker aallyn`  

`logout`  

I did get an error when running that second to last line about docker not being a recognized group. To get around that, I ran `sudo groupadd docker`
and then  `usermod -a -G docker your_user`. That seemed to fix things. 

7. After completing those steps, it was time to install docker and get things set up on the droplet. Danny had some stuff about SSL certificates before this, which I ended up skipping. For the docker installation, I first checked that I was still in the right directory, which is the directory that either has (or will have if it you do Digital Ocean first and then docker) all of the docker container information. From there, I connected to the droplet by running `ssh your_user@IPaddressoftheDigitalOceanDroplet`. If a problem: https://www.digitalocean.com/community/questions/error-permission-denied-publickey-when-i-try-to-ssh. After connecting to the droplet, and while still in the terminal, I ran the following lines to install docker:  
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
  
9. With docker installed, it's time to set up all of the files needed. Danny does this on the fly. For me, I think if I do this again, I will likely just jump to step one in the above section that covers how to [set up a docker container as a GitHub repository](#Setting up a docker container repository). With all of those pieces taken care of, then it just became a matter of cloning the docker Github repository onto the droplet. To do that, I copied the address from github.com for the docker repo and then typed `git clone docker_repo_url` into the command line. Then, I did `cd ~/docker_repo_name`. Within that folder, I created both a "secret.env" file and a "GitHubPAT.text" file using `nano secret.env` and then `nano GitHubPAT.txt`. Finally, I typed `make up`, which again, only works because I had made a "makefile" earlier when setting up the docker container.

10. To access and use the container on the DigitalOcean droplet, I opened a web broswer to web "http://IPaddressoftheDigitalOceanDroplet:8787" as opposed to "http://localhost:8787". 

**Connection errors** When I was making quite a few edits to the Dockerfiles and pulling them back down and running `make up`, I ran into a connection error when I went and tried to connect to the droplet through the web browser. I have no idea what caused this and ended up having to destroy the droplet and start over.

# Run git and then google stuff


11. One thing that was still missing was the mounting of the block storage volume. This is simply because I did the docker work first and I didn't know the block storage volume name. With the name after setting up the Digitial Ocean bits, I then edited the `docker-compose.yaml` file "volumes" section as 
      `- $HOME/:/home/aallyn/`
      `- /mnt/volume_nyc1_01/:/home/aallyn/block_storage/`

12. After doing all this, I took a snapshot of the image as recommended by Danny. I did this before completing the final piece of the puzzle, which involved connecting the block storage to a folder on my Dropbox account. For this, I followed Danny's instructions exactly, with one small edit. I downloaded the "dropbox.py" script as he suggested by running 

11. Dropbox all the same except for adding 
  `sudo apt install libc6 libglapi-mesa libxdamage1 libxfixes3 libxcb-glx0 libxcb-dri2-0 libxcb-dri3-0 libxcb-present0 libxcb-sync1 libxshmfence1 libxxf86vm1` before running the phython3 command.

12. Having to delete the know_host ssh key each time /Users/aallyn/.ssh/known_hosts

13. Lost dropbox in snapshot, trying something else...
`cd ./mnt/volume_nyc1_03 `
`curl -Lo dropbox-linux-x86_64.tar.gz https://www.dropbox.com/download?plat=lnx.x86_64`
`sudo mkdir -p ./opt/dropbox`
`sudo tar xzfv dropbox-linux-x86_64.tar.gz --strip 1 -C ./opt/dropbox`
`./opt/dropbox/dropboxd`

Still nothing....
`wget -O /mnt/volume_nyc1_03/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py"`
nano /mnt/volume_nyc1_03/dropbox.py
python3 /mnt/volume_nyc1_03/dropbox.py start -i
python3 dropbox.py start
python3 dropbox.py throttle 'unlimited' 'unlimited'
cd ./Dropbox
python3 /mnt/volume_nyc1_03/dropbox.py exclude add 'Andrew' 'Waterfowl' 'Atticus' 'Camera Uploads'

Now, instead of unmounting before the snapshot (like what Danny does) Going to try to snapshot just after powering down...

On restart...
cd /mnt/volume_nyc1_03
python3 dropbox.py start

That worked!!!!


# Docker hub updating -- need to do this so each worker has access to everything they need
docker login
docker build .
docker tag ajall1985/gmri_rocker:tag name
docker push ajall1985/gmri_rocker:tag name

Then Andrew Heiss tutorial -- 

# Other helpful resources #
For more help, check out:  
- Jenny Bryan (Git/GitHub and R): https://happygitwithr.com/  
- Andrew Heiss (R, DigitalOcean, and R's "future" package): https://www.andrewheiss.com/blog/2018/07/30/disposable-supercomputer-future/  
- Andrew Heiss (Docker, RStudio and DigitalOcean): https://www.andrewheiss.com/blog/2017/04/27/super-basic-practical-guide-to-docker-and-rstudio/  
- Derek Powell (Docker, Git/GitHub and Docker Hub): http://www.derekmpowell.com/posts/2018/02/docker-tutorial-2/  
- Joel Nitta (https://www.joelnitta.com/post/how-to-run-an-r-analysis-anywhere/how-to-run-an-r-analysis-anywhere/)  
- Brian Hogan (https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) 


> options(httr_oob_default=TRUE)
> drive_auth()