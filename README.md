
### Summary

This repository is based on [progrium/sshcommand](https://github.com/progrium/sshcommand) to provide a server endpoint where a piped in tarred data stream is extracted into a specified volume.

References:

* http://meinit.nl/using-tar-and-ssh-to-efficiently-copy-files-preserving-permissions

#### TODO:

* Change tar forced-command to take an environment variable for target_dir, allowing to run tar_receive with volumes_from other containers
* Provide a mechanism to clear the target directory prior to piping in the new data
* Add feedback about the command execution to the ssh client

### Setup

To run a container listening for tar pushes, follow the following 2 sections:

#### VPS setup:

1. Run tar_receive server which has tar user to received tarred input streams:

        tar_target=/usr/share/html/

        #the container tar user has `uid` & `gid` 1000
        #userid 1000 needs write permissions over $tar_target
        chown -R 1000:1000 $tar_target
        docker run -d --name tar_receive -v $tar_target:/target -p <port>:22 so0k/tarreceive:1.0

2. for each developer, instal public key of developer to enable tar pushing

        cat ~/.ssh/authorized_keys | grep ssh-rsa | docker exec -i tar_receive sshcommand acl-add tar <name>

#### Client setup:

1. As the host key changes each time the container restarts, it might be advisable to reduce host key checking (yet this is not without risk):
   (Replace localhost with hostname of VPS)

        gitserver=localhost

        cat >> ~/.ssh/config << EOF
        
        Host $gitserver
          UserKnownHostsFile=/dev/null
          StrictHostKeyChecking=no
          IdentityFile ~/.ssh/id_digitalocean
        EOF

### Client Usage:

tar the contents of the desired directory to the server:

    (cd /my/folder/; tar cpf - * | ssh -p <port> tar@<server>)

### Building the images

building the base alpine sshd/sshcommand image:

    docker build -f sshcommand.Dockerfile -t so0k/docker-sshcommand:1.0 .
    docker tag so0k/docker-sshcommand:1.0 so0k/docker-sshcommand:latest

building the tar receive image:

    docker build -f tar.Dockerfile -t so0k/tarreceive:1.0 .
    docker tag so0k/tarreceive:1.0 so0k/tarreceive:latest
