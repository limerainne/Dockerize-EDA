FROM ubuntu:18.04 AS installer
ARG repo_sed=s#://archive.ubuntu.com#://kr.archive.ubuntu.com#g

# 'cshell' is required to run the installer
RUN sed -i -e "${repo_sed}" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends csh \
    && rm -rf /var/lib/apt/lists/*

# information of the tool to be installed in this image
# TODO how to deduplicate below arguments declaration
ARG base_dir=/usr/synopsys
ARG tool=hspice
ARG version=N-2017.12

ARG installer_version=v4.1


# copy installer and installation package temporarily
COPY package/installer_${installer_version} /tmp/installer/
COPY package/${tool}_v${version} /tmp/package/

# batch install target package
RUN mkdir -p ${base_dir} \
    && /tmp/installer/SynopsysInstaller_${installer_version}.run -dir ${base_dir}/installer_${installer_version} \
    && echo 'yes' | USER=docker ${base_dir}/installer_${installer_version}/batch_installer -install_as_root -source /tmp/package/ -target ${base_dir}/ -allprods \
    && rm -rf /tmp/package/ \
    && rm -rf /tmp/installer/ \
    && rm -rf ${base_dir}/installer_${installer_version}


# NOTE using multi-stage image build; avoid including installer package in the final image
FROM ubuntu:18.04
ARG repo_sed=s#://archive.ubuntu.com#://kr.archive.ubuntu.com#g

# install required library to run Synopsys tool and X11 library to show GUI
# NOTE HSPICE requires libxml2 also
RUN sed -i -e "${repo_sed}" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    csh libxss1 libsm6 libice6 libxft2 libjpeg62 libtiff5 libmng2 libxml2\
    && apt-get install -y --no-install-recommends xserver-xorg-video-dummy xserver-xorg-input-void xserver-xorg-core xinit x11-xserver-utils \
    && echo "deb http://security.ubuntu.com/ubuntu xenial-security main" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y -t xenial libpng12-0 \
    && rm -rf /var/lib/apt/lists/*
# # using somewhat lighter X11 package rather than xorg; 'x11-apps' is not applicable
# ref: https://git.devuan.org/dev1fanboy/Upgrade-Install-Devuan/wikis/minimal-xorg-install
# # WORKAROUND install libpng12-0 package from Xenial, which is removed from Bionic
# ref: https://www.linuxuprising.com/2018/05/fix-libpng12-0-missing-in-ubuntu-1804.html

# WORKAROUND link outdated library files required from Synopsys tools
# WORKAROUND set default shell as Bash to avoid error from script included in the tool
RUN ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/x86_64-linux-gnu/libtiff.so.3 \
    && ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1 \
    && update-alternatives --install /bin/sh sh /bin/bash 20

# WORKAROUND Ubuntu 18.04 does not have terminfo files in /usr/share/terminfo/
RUN cp -r /lib/terminfo/. /usr/share/terminfo/

# copy actual tool to be run in this image
ARG base_dir=/usr/synopsys
ARG tool=hspice
ARG version=N-2017.12


# just copy installed package from intermediate image
COPY --from=installer ${base_dir}/ ${base_dir}/

# set path to the tool executable
# NOTE HSPICE has different path to executable
ENV PATH ${base_dir}/${tool}/${version}/hspice/bin:$PATH

# default command when running this image
CMD "hspice" -I

