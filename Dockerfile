# Use Go base image
FROM golang:1.24-bullseye

#RUN apt-get update && apt-get install -y --no-install-recommends gnupg ca-certificates
RUN apt-get update


# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs

# Verify Node.js installation
RUN node -v && npm -v

# Update package list and install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates mailcap curl jq libnss-ldap

WORKDIR /build
COPY . .

RUN make build

VOLUME /srv
EXPOSE 80

WORKDIR /
COPY healthcheck.sh /healthcheck.sh
COPY docker_config.json /.filebrowser.json
RUN mv /build/filebrowser /filebrowser

RUN chmod +x /healthcheck.sh  # Make the script executable
HEALTHCHECK --start-period=2s --interval=5s --timeout=3s CMD /healthcheck.sh || exit 1

ENTRYPOINT [ "/filebrowser" ]
