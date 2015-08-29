FROM so0k/docker-sshcommand:1.1

#create tar command extracting to $TARGET_DIR or default to /target/
#ensure entry script updates /etc/profile to export target_dir variable for all users
COPY tarreceive /usr/bin/tarreceive
RUN mkdir -p /target/ && \
    sed -i '9iecho "export TARGET_DIR=\"${TARGET_DIR:-/target/}\"" >> /etc/profile' /usr/bin/entry.sh && \
    chmod +x /usr/bin/tarreceive && \
    sshcommand create tar 'tarreceive'