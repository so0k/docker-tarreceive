FROM alpine:3.2
# base image for sshcommand containers
#  
# this image does not provision an ssh user to run under and should only be used as a base of sshcommand images
#
# alpine container with sshd and sshcommand
# references:
#   https://hub.docker.com/r/chamunks/alpine-openssh/~/dockerfile/
#   https://github.com/macropin/docker-sshd

RUN apk update && \
    apk add bash openssh && \
    rm -rf /var/cache/apk/* 

COPY sshd_config /etc/ssh/sshd_config

# RUN apk add --update wget ca-certificates && \
#     rm -rf /var/cache/apk/* && \
#     wget -O /usr/bin/sshcommand https://raw.githubusercontent.com/progrium/sshcommand/e6d1655ffb4e381910d14eeb92dd9b32456a5fd2/sshcommand && \
#     chmod +x /usr/bin/sshcommand

#had to customize sshcommand to work on alpine
#need to use entry.sh to generate host key on container start   
COPY sshcommand entry.sh /usr/bin/
RUN chmod +x /usr/bin/sshcommand /usr/bin/entry.sh

ENTRYPOINT ["/usr/bin/entry.sh"]

VOLUME ["/etc/ssh/"]

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
# docker build -f sshcommand.Dockerfile -t so0k/docker-sshcommand:1.0 .