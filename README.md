### Summary
[![](https://badge.imagelayers.io/so0k/tarreceive:latest.svg)](https://imagelayers.io/?images=so0k/tarreceive:latest 'Get your own badge on imagelayers.io')

This repository is based on [progrium/sshcommand](https://github.com/progrium/sshcommand) which creates a system user made for running a single command via SSH and manages an ACL of SSH keys (authorized_keys). This allows us to provide a server endpoint where a piped in `tar` data stream is extracted into an environment variable specified volume.

[source on github](https://github.com/so0k/docker-tarreceive)

References:

* http://meinit.nl/using-tar-and-ssh-to-efficiently-copy-files-preserving-permissions

Notes:

* If you have multiple developers, you should use a version control system and Continuous Deployment solution instead of this!
* I do not guarantuee there is no exploit to compromise the host

### Table Of Contents

<!-- MarkdownTOC depth=4 autolink=true bracket=round -->

- [TODO](#todo)
- [Setup](#setup)
    - [VPS setup:](#vps-setup)
    - [Client setup:](#client-setup)
- [Client Usage](#client-usage)
    - [Linux/OSX](#linuxosx)
    - [Windows](#windows)
- [Building the images](#building-the-images)

<!-- /MarkdownTOC -->

#### TODO

* ~~Changed tar forced-command to take an environment variable for target_dir, allowing to run tar_receive with `--volumes-from` other containers~~
* ~~Provide a mechanism to clear the target directory prior to piping in the new data~~
* ~~Add feedback about the command execution to the ssh client~~
* Add powershell script for Windows developers (msys git / plink)

### Setup

To run a container listening for tar pushes, follow the following 2 sections:

#### VPS setup:

1. Run tar_receive server which has tar user to received tarred input streams (the container tar user has `uid` & `gid` 1000):

        tar_target=/usr/share/nginx/html/

        #userid 1000 needs write permissions over $tar_target
        chown -R 1000:1000 $tar_target
        docker run -d --name tar_receive -v $tar_target:/target -p <port>:22 so0k/tarreceive:1.2

    or link tar_receive to another container and specify the target directory through `$TARGET_DIR` env var
    
        docker run -d --name tar_receive --volumes-from nginx -e "TARGET_DIR=/usr/share/nginx/html/" -p <port>:22 so0k/tarreceive:1.2

2. for each developer, instal public key of developer to enable tar pushing (for example, adding all currently authorized users to tar command)

        cat ~/.ssh/authorized_keys | grep ssh-rsa | docker exec -i tar_receive sshcommand acl-add tar <name>

#### Client setup:

1. As the host key changes each time the container is created/ran, it might be advisable to reduce host key checking (yet this is not without risk):
   (Replace localhost with hostname of VPS)

        gitserver=localhost

        cat >> ~/.ssh/config << EOF
        
        Host $gitserver
          UserKnownHostsFile=/dev/null
          StrictHostKeyChecking=no
          IdentityFile ~/.ssh/id_digitalocean
        EOF

### Client Usage 

#### Linux/OSX

If you have the permission to run the tar sshcommand, use the following command to tar the contents of a directory to the server:

    (cd /my/directory/; tar cpf - * | ssh -p <port> tar@<server>)

use the following command to clear the target folder prior to sending the contents of a directory through tar to the server:

    (cd /my/directory/; tar cpf - * | ssh -p <port> tar@<server> clean)

To see all short usage instructions use

    ssh -p <port> tar@<server> help

#### Windows

Coming soon

### Building the images

building the base alpine sshd/sshcommand image:

    docker build -f sshcommand.Dockerfile -t so0k/docker-sshcommand:1.1 .
    docker tag so0k/docker-sshcommand:1.1 so0k/docker-sshcommand:latest

building the tar receive image:

    docker build -f tar.Dockerfile -t so0k/tarreceive:1.2 .
    docker tag so0k/tarreceive:1.2 so0k/tarreceive:latest
