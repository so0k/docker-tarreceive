FROM so0k/docker-sshcommand:1.0

#create tar extract to /target/ command
RUN mkdir -p /target/ && \
    sshcommand create tar "tar xpf - -C /target/" && \
    chown tar:tar /target

VOLUME ["/target","/home/tar/.ssh"]
# ---BUILD
# docker build -f tar.Dockerfile -t so0k/tarreceive:1.0 .
# ---DEPLOY (server)
# chown -R 1000:1000 /home/core/test-target
# docker run -d --name tarreceive -v /home/core/test-target/:/target -p 55583:22 so0k/tarreceive:1.0
# cat ~/.ssh/authorized_keys | grep ssh-rsa | docker exec -i tarreceive sshcommand acl-add tar <name>
# ---USAGE (client)
# (cd /my/folder/; tar cpf - * | ssh -p 55583 tar@10.40.0.5)