FROM so0k/docker-sshcommand:1.1

#create tar command extracting to $TARGET_DIR or default to /target/
#ensure entry script updates /etc/profile to export target_dir variable for all users
RUN mkdir -p /target/ && \
    sed -i '9iecho "export TARGET_DIR=\"${TARGET_DIR:-/target/}\"" >> /etc/profile' /usr/bin/entry.sh && \
    sshcommand create tar 'eval tar xf - -C $TARGET_DIR'