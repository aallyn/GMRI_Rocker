# GMRI_Rocker

# Steps to set this up
1. Create a new repository on GitHub (GMRI_Rocker)
2. On local machine, cd to where you want to clone the new repository and then type
    `git clone your_repo_link`
3. Create the necessary docker files. 
    a. First, need a Dockerfile. To start, check out the (rocker project)[https://hub.docker.com/u/rocker]. There's a variety of different images available depending on your particular analysis (for example, if you are doing a lot of machine learning work, you might be more interested in the rocker/ml-verse). For this docker container, we are going to build from the rocker/geospatial image. After identifying the image that is best aligned with our needs, we create a new file `Dockerfile` and then write `FROM rocker/your_desired_image`. While this gives us a nice start, there are likely going to be other things we want to include. For that, it seemed easiest to write a piece of piece of code (`Preliminaries.R`) and then write directions within the `DockerFile` to copy the file and then run it. 
4. With the new files created, git add them all, commit and then push your local changes to GitHub
    `git add .`
    `git commit -m "Initial commit"`
    `git push origin master`
5. Go to DockerHub and after (creating an account and linking the account to your GitHub account)[https://docs.docker.com/docker-hub/builds/link-source/], create a new repository. In following the options, you should be able to create an automated build for your new DockerHub repository that is linked to your GitHub repository. This means that if there is a change made, commited and pushed to the GitHub repo (for example, editing `Preliminaries.R`), it will trigger docker to build a new image based that includes the changes.
6. Back in the terminal, run the image inside a docker container using the `docker run` call 
    `docker run -d -p 8787:8787 -e USER=add_a_username -e PASSWORD=add_a_password -e ROOT=true your_dockerhub_repo_name`
7. After running this command, you should see evidence of pulling the information from DockerHub and then using that to build the container. Once this is done, we open the container in a local web browser. to do that, we will need the IP address of our local machine, which we get by running
    `pconfig getifaddr en0`
    Then, we can open a web browswer and navigate to
    `http://your_ip_address:8787` 
    When you have done that, you should be prompted by an RStudio window to enter your username and password. Do that, and now you should see an RStudio set up in the web browser. 
8. Next, we can get our code and data into the container. To do this, go to GitHub account online and copy the address of the repo that has the code/data/etc. Start a new project in the broswer RStudio instance and select version controlled, Git, and the address for the repo you just copied. Open up a terminal window in the browser RStudio instance and type the following to make the full connection to the GitHub repo
    `git remote add origin https://linktotherepoyoucopied.git`
        * This should return that the remote already exists if you did the above step correctly.
    `git config --global user.name "Your github user name"`
    `git config --global user.email "Your github email"`
    `git config --global user.password "Your github password"`
    `git pull origin master`
        * This should return a message that things are already up to date
9. Work away, just like you would normally do! When you are done for the day, commit and push your changes from docker container to GitHub online.
10. After our work is done, ready to close docker container and remove it to clean things up. 
    `docker ps`
    `docker stop your_container_id`
    `docker rm your_container_id`
