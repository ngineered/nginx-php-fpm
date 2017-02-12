[![Travis](https://img.shields.io/docker/pulls/richarvey/nginx-php-fpm.svg?style=flat-square)]()
[![Travis](https://img.shields.io/docker/stars/richarvey/nginx-php-fpm.svg?style=flat-square)]()
[![Travis](https://img.shields.io/travis/ngineered/nginx-php-fpm.svg?style=flat-square)]()

## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm, with the ability to pull website code from git. The container also has the ability to update templated files with variables passed to docker in order to update your settings. There is also support for lets encrypt SSL support.

### Git repository
The source files for this project can be found here: [https://github.com/ngineered/nginx-php-fpm](https://github.com/ngineered/nginx-php-fpm)

If you have any improvements please submit a pull request.
### Docker hub repository
The Docker hub build can be found here: [https://registry.hub.docker.com/u/richarvey/nginx-php-fpm/](https://registry.hub.docker.com/u/richarvey/nginx-php-fpm/)
## Versions
| Tag | Nginx | PHP | Alpine |
|-----|-------|-----|--------|
| latest | 1.11.9 | 7.1.1 | 3.4 |
| php71  | 1.11.9 | 7.1.1 | 3.4 |
| php5   | 1.11.5 | 5.6.29 | 3.4 |

**PLEASE NOTE: PHP7.1 is now the default and support for php5 will be dropped soon**

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/ngineered/nginx-php-fpm
.git
docker build -t nginx-php-fpm:latest .
```

## Pulling from Docker Hub
```
docker pull richarvey/nginx-php-fpm
```

## Running
To simply run the container:
```
sudo docker run -d richarvey/nginx-php-fpm
```

You can then browse to ```http://<DOCKER_HOST>``` to view the default install files. To find your ```DOCKER_HOST``` use the ```docker inspect``` to get the IP address.

### Available Configuration Parameters
The following flags are a list of all the currently supported options that can be changed by passing in the variables to docker with the -e flag.

 - **GIT_REPO** : URL to the repository containing your source code. If you are using a personal token, this is the https URL without https://, e.g github.com/project/ for ssh prepend with git@ e.g git@github.com:project.git
 - **GIT_BRANCH** : Select a specific branch (optional)
 - **GIT_EMAIL** : Set your email for code pushing (required for git to work)
 - **GIT_NAME** : Set your name for code pushing (required for git to work)
 - **GIT_USE_SSH** : Set this to 1 if you want to use git over SSH (instead of HTTP), useful if you want to use Bitbucket instead of GitHub
 - **SSH_KEY** : Private SSH deploy key for your repository base64 encoded (requires write permissions for pushing)
 - **GIT_PERSONAL_TOKEN** : Personal access token for your git account (required for HTTPS git access)
 - **GIT_USERNAME** : Git username for use with personal tokens. (required for HTTPS git access)
 - **WEBROOT** : Change the default webroot directory from `/var/www/html` to your own setting
 - **ERRORS** : Set to 1 to display PHP Errors in the browser
 - **HIDE_NGINX_HEADERS** : Disable by setting to 0, default behaviour is to hide nginx + php version in headers
 - **PHP_MEM_LIMIT** : Set higher PHP memory limit, default is 128 Mb
 - **PHP_POST_MAX_SIZE** : Set a larger post_max_size, default is 100 Mb
 - **PHP_UPLOAD_MAX_FILESIZE** : Set a larger upload_max_filesize, default is 100 Mb
 - **DOMAIN** : Set domain name for Lets Encrypt scripts
 - **REAL_IP_HEADER** : set to 1 to enable real ip support in the logs
 - **REAL_IP_FROM** : set to your CIDR block for real ip in logs
 - **RUN_SCRIPTS** : Set to 1 to execute scripts
 - **PGID** : Set to GroupId you want to use for nginx - see below for explanation
 - **PUID** : Set to UserID you want to use for nginx - see below for explanation

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

### Dynamically Pulling code from git
One of the nice features of this container is its ability to pull code from a git repository with a couple of environmental variables passed at run time. Please take a look at our recommended [repo layout guidelines](https://github.com/ngineered/nginx-php-fpm/blob/master/docs/repo_layout.md).

There are two methods of pulling code from git, you can either use a Personal Token (recommended method) or an SSH key.

**Note:** We would recommend using a git personal token over an SSH key as it simplifies the set up process. To create a personal access token on Github follow this [guide](https://help.github.com/articles/creating-an-access-token-for-command-line-use/).

#### Personal Access token

You can pass the container your personal access token from your git account using the __GIT_PERSONAL_TOKEN__ flag. This token must be setup with the correct permissions in git in order to push and pull code.

Since the access token acts as a password with limited access, the git push/pull uses HTTPS to authenticate. You will need to specify your __GIT_USERNAME__ and __GIT_PERSONAL_TOKEN__ variables to push and pull. You'll need to also have the __GIT_EMAIL__, __GIT_NAME__ and __GIT_REPO__ common variables defined.

```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' richarvey/nginx-php-fpm:latest
```

To pull a repository and specify a branch add the __GIT_BRANCH__ environment variable:
```
docker run -d -e 'GIT_EMAIL=email_address' -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'GIT_PERSONAL_TOKEN=<long_token_string_here>' -e 'GIT_BRANCH=stage' richarvey/nginx-php-fpm:latest
```
#### SSH keys

##### Preparing your SSH key
The container has the option for you to pass it the __SSH_KEY__ variable with a **base64** encoded **private** key. First generate your key and then make sure to add it to github and give it write permissions if you want to be able to push code from the container. Then run:
```
base64 -w 0 /path_to_your_private_key
```
**Note:** Copy the output, but be careful not to copy your prompt

##### Running with SSH Keys

To run the container and pull code simply specify the GIT_REPO URL including *git@* and then make sure you have also supplied your base64 version of your ssh deploy key:
```
sudo docker run -d -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' richarvey/nginx-php-fpm:latest
```

To pull a repository and specify a branch add the GIT_BRANCH environment variable:
```
sudo docker run -d -e 'GIT_NAME=full_name' -e 'GIT_USERNAME=git_username' -e 'GIT_REPO=github.com/project' -e 'SSH_KEY=BIG_LONG_BASE64_STRING_GOES_IN_HERE' -e 'GIT_BRANCH=stage' richarvey/nginx-php-fpm:latest
```

### Custom Nginx Config files
Sometimes you need a custom config file for nginx to achieve this read the [Nginx config guide](https://github.com/ngineered/nginx-php-fpm/blob/master/docs/nginx_configs.md) 

#### REAL IP / X-Forwarded-For Headers
If you operate your container behind a load balancer, an ELB on AWS for example, you need to configure nginx to get the real IP and not the load balancer IP in the logs by using the X-Forwarded-For. We've provided some handy flags to let you do this. You need to set both of these to get this to work:
```
-e "REAL_IP_HEADER=1"
-e "REAL_IP_FROM=Your_CIDR"
```
For example:
```
docker run -d -e "REAL_IP_HEADER=1" -e "REAL_IP_FROM=10.1.0.0/16" richarvey/nginx-php-fpm:latest
```

### Scripting and Templating
Please see the [Scripting and templating guide](https://github.com/ngineered/nginx-php-fpm/blob/master/docs/scripting_templating.md) for more details.

### Lets Encrypt support
This container includes support to easily manage lets encrypt certificates. Please see the [Lets Encrypt guide](https://github.com/ngineered/nginx-php-fpm/blob/master/docs/lets_encrypt.md) for more details.

### Install PHP Modules

First of all drop into the container:
```
docker exec -t -i nginx /bin/bash
```
Then configure and install your module:
```
/usr/local/bin/docker-php-ext-configure sockets
/usr/local/bin/docker-php-ext-install sockets
```
Now restart php-fpm:
```
supervisorctl restart php-fpm
```

## Special Git Features
Specify the ```GIT_EMAIL``` and ```GIT_NAME``` variables for this to work. They are used to set up git correctly and allow the following commands to work.

### Push code to Git
To push code changes made within the container back to git run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/push
```

### Pull code from Git (Refresh)
In order to refresh the code in a container and pull newer code from git run:
```
sudo docker exec -t -i <CONTAINER_NAME> /usr/bin/pull
```
## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
### WebRoot
You can set your webroot in the container to anything you want using the ```WEBROOT``` variable e.g -e "WEBROOT=/var/www/html/public". By default code is checked out into /var/www/html/ so if your git repository does not have code in the root you'll need to use this variable.
