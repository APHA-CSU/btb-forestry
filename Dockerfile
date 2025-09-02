FROM ubuntu:24.04

####################### METADATA ##########################
LABEL Maintainer="Richard Ellis <richard.ellis@apha.gov.uk>"
LABEL base.image=ubuntu:24.04
LABEL software="bTB-foresty"
LABEL about.documentation="https://github.com/APHA-CSU/bTB-foresty"

#################### INSTALL BASICS #######################

RUN apt-get update && apt-get install --yes --no-install-recommends \
    wget \
    curl \
    unzip \
    gawk \
    gcc \
    git \
    make \
    python3-dev \
    python3-venv \
    python3-pandas \
    zlib1g-dev \
    libsqlite3-dev \
    snp-sites \
    jq \
    pip \
    libdbus-glib-1-2

################## INSTALL DEPENDANCIES ###################

# augur
# install in python venv and generate symlink
RUN git clone https://github.com/APHA-CSU/augur.git && \
    cd augur && \
    python3 -m venv /usr/local/libexec/augur && \
    /usr/local/libexec/augur/bin/pip install . && \
    ln -s /usr/local/libexec/augur/bin/augur /usr/local/bin/augur

# aws-cli
RUN curl -k "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# snp-dists
RUN git clone https://github.com/tseemann/snp-dists.git && \
    cd snp-dists && \
    make

# snp-sites - installed using apt above

# mega-cc
# Requires manunal install of libgconf
RUN wget http://kr.archive.ubuntu.com/ubuntu/pool/universe/g/gconf/gconf2-common_3.2.6-6ubuntu1_all.deb && \
    apt-get install -y ./gconf2-common_3.2.6-6ubuntu1_all.deb && \
    rm gconf2-common_3.2.6-6ubuntu1_all.deb
RUN wget http://kr.archive.ubuntu.com/ubuntu/pool/universe/g/gconf/libgconf-2-4_3.2.6-6ubuntu1_amd64.deb && \
    apt-get install -y ./libgconf-2-4_3.2.6-6ubuntu1_amd64.deb && \
    rm libgconf-2-4_3.2.6-6ubuntu1_amd64.deb
RUN wget --no-check-certificate https://megasoftware.net/do_force_download/mega-cc_11.0.13-1_amd64.deb && \
    apt-get install -y ./mega-cc_11.0.13-1_amd64.deb && \
    rm mega-cc_11.0.13-1_amd64.deb