FROM alpine:3.10

ARG PUID=211
ARG PGID=211

# Install OpenSSH server and Gitolite
# Unlock the automatically-created git user
RUN set -x \
    && apk add --no-cache gitolite openssh \
    && deluser git \
    && addgroup -g ${PGID} -S git \
    && adduser -u ${PUID} -S -D -H -h /var/lib/git -s /bin/sh -G git -g git git \
    && chown git:git /var/lib/git \
    && passwd -u git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH server
CMD ["sshd"]
