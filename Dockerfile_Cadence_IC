FROM ubuntu:18.04 AS installer
ARG repo_sed=s#://archive.ubuntu.com#://kr.archive.ubuntu.com#g

# Java 6+ might be required to run the installer
RUN sed -i -e "${repo_sed}" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-8-jre \
    && rm -rf /var/lib/apt/lists/*

# information of the tool to be installed in this image
# TODO how to deduplicate below arguments declaration
ARG base_dir=/usr/cadence
ARG tool=IC
ARG version=617

ARG installer_dir=InstallScape


# copy installer and installation package temporarily
COPY package/${installer_dir} /tmp/installer/
COPY package/${tool}${version} /tmp/package/

# batch install target package
RUN mkdir -p ${base_dir}/ \
    && /tmp/installer/iscape/bin/iscape.sh -batch majorAction=InstallFromArchive \
         archiveDirectory=/tmp/package/ installDirectory=${base_dir}/${tool}${version} \
    && rm -rf /tmp/package/ \
    && rm -rf /tmp/installer/


# NOTE using multi-stage image build; avoid including installer package in the final image
FROM ubuntu:18.04
ARG repo_sed=s#://archive.ubuntu.com#://kr.archive.ubuntu.com#g

# Java 6+ might be required to run actual software
RUN sed -i -e "${repo_sed}" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends openjdk-8-jre \
    && rm -rf /var/lib/apt/lists/*

# install required library to run Cadence tool and X11 library to show GUI
RUN sed -i -e "${repo_sed}" /etc/apt/sources.list \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends libxtst6:i386 libxext6:i386 libxi6:i386 ksh csh \
    && apt-get install -y --no-install-recommends xserver-xorg-video-dummy xserver-xorg-input-void xserver-xorg-core xinit x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*
# # using somewhat lighter X11 package rather than xorg; 'x11-apps' is not applicable
# ref: https://git.devuan.org/dev1fanboy/Upgrade-Install-Devuan/wikis/minimal-xorg-install

# copy actual tool to be run in this image
ARG base_dir=/usr/cadence
ARG tool=IC
ARG version=617

# just copy installed package from intermediate image
COPY --from=installer ${base_dir}/ ${base_dir}/

# set path to the tool executable
ENV PATH ${base_dir}/${tool}${version}/tools/bin:$PATH

# let 64-bit binary to be executed
ENV CDS_AUTO_64BIT "ALL"
# force set environment for OpenAccess
ENV OA_UNSUPPORTED_PLAT "linux_rhel50_gcc48x"

# set path to the tool executable
CMD "virtuoso"

