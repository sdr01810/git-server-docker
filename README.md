# git-server-docker
A Docker image based on Alpine that provides a Git SSH server.
Available on [GitHub](https://github.com/jkarlosb/git-server-docker) and
[Docker Hub](https://hub.docker.com/r/jkarlos/git-server-docker/)

!["image git server docker" "git server docker"](https://raw.githubusercontent.com/jkarlosb/git-server-docker/master/git-server-docker.jpg)

### Basic Usage

How to run the container at port 2222 with two volumes: 
a 'keys' volume for public keys, and 'repos' volume for git repositories:

	$ docker run -d -p 2222:22 -v ~/git-server/keys:/git-server/keys -v ~/git-server/repos:/git-server/repos jkarlos/git-server-docker

How to use a public key:

	Copy the public part of your public/private key pair to the keys folder: 
	- From your local host: $ cp ~/.ssh/id_rsa.pub ~/git-server/keys
	- From a remote host: $ scp ~/.ssh/id_rsa.pub user@host:~/git-server/keys
	
	Once you've finished making changes in the keys folder, 
	you need to restart the container:
	$ docker restart <container-id>
	
How to check that the container works (you must first upload your public key):

	$ ssh git@<container-ip-address> -p 2222
	...
	Welcome to git-server-docker!

	You've authenticated successfully, but this
	git server does not provide interactive shell access.
	...

How to create a new repo outside of the git server:

	$ cd my-repo
	$ git init --shared=true
	$ git add .
	$ git commit -m "Initial commit"
	$ cd ..
	$ git clone --bare my-repo my-repo.git

How to upload a repo to the git server:

	Copy your repo's .git directory to the repos folder: 
	- From your local host: $ mv my-repo.git ~/git-server/repos
	- From a remote host: $ scp -r my-repo.git user@host:~/git-server/repos

How to clone a repo from the git server:

	$ git clone ssh://git@<container-ip-address>:2222/git-server/repos/my-repo.git

### Arguments

* **Exposed ports**: 22
* **Volumes**:
 * */git-server/keys*: Stores public ssh keys for each user.
 * */git-server/repos*: Stores the git repositories.

### SSH Keys

How to generate a public/private key pair for use with ssh:

	Generate a standard RSA key pair:
	- From your local host: $ ssh-keygen -t rsa

How to quickly upload the public part of your ssh key to the git server:

	Upload it to the host that executes the git-server-docker container:
	$ scp ~/.ssh/id_rsa.pub user@host:~/git-server/keys

### Build Image

How to make the docker image:

	$ docker build -t git-server-docker .
	
### Docker Compose

You can edit docker-compose.yml and run this container with docker-compose:

	$ docker-compose up -d

