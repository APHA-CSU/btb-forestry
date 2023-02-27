FROM ubuntu:22.04

####################### METADATA ##########################
LABEL Maintainer="Richard Ellis <richard.ellis@apha.gov.uk>"
LABEL base.image=ubuntu:22.04
LABEL software="bTB-foresty"
LABEL about.documentation="https://github.com/APHA-CSU/bTB-foresty"

#################### INSTALL BASICS #######################

RUN apt-get update && apt-get install --yes --no-install-recommends \
    wget \
    curl \
    unzip \
    gcc \
    git \
    make \
    python3-dev \
    zlib1g-dev \
    libsqlite3-dev \
    python3-pip \
    snp-sites

################## INSTALL DEPENDANCIES ###################

# augur
RUN git clone https://github.com/APHA-CSU/augur.git && \
    cd augur && \
    python3 -m pip install .

# aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# snp-dists
RUN git clone https://github.com/tseemann/snp-dists.git && \
    cd snp-dists && \
    make

# snp-sites - installed using apt above

# mega-cc
RUN wget https://megasoftware.net/do_force_download/mega-cc_11.0.13-1_amd64.deb && \
    apt-get install -y ./mega-cc_11.0.13-1_amd64.deb && \
    rm mega-cc_11.0.13-1_amd64.deb
