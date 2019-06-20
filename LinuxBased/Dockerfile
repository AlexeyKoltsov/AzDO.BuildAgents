ARG baseImage

FROM ${baseImage}

COPY scripts/*.sh /tmp/
RUN \
    apt-get update &&\
    chmod +x /tmp/*.sh &&\
    /bin/bash -l -c /tmp/install-azcli.sh &&\
    /bin/bash -l -c /tmp/install-pwsh.sh &&\
    apt-get autoremove &&\
    rm -rf /var/lib/apt/lists/*

