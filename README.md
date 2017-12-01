# [WIP] Dockerize scripts for commercial EDA tools

I don't think dockerizing EDA tools is somewhat useful, but here is the `Dockerfile`s for dockerizing popular EDA tools!

## CAVEAT
  - I failed to achieve X11 forwarding. In other words, with this image you cannot open GUI windows.
  - Using Ubuntu (14.04) as a base image, the size of generated images is larger than desired.
  - Did not test uploading to "private" docker registry.
    - (you should not upload image containing commeiclal tool to public docker registry, of course ;-) )
  - Intermediate image does not removed automatically. You have to remove by yourself for now.

## Prerequisites
  - Docker 17.05+ (this script utilizes multi-stage build feature)
  - Installer and installation package of the tool you want to dockerize
     - This repository consists of just `Dockerfile`s, not actual images or installer packages

## Generating an image
  
  - First, clone this repository to your workstation.
  - Copy (or bind mount) installer and installation package to the subdirectory
     - Refer to shell scripts for bind-mounting installation files from other path
  - Execute below command to create an image.
`$ sudo docker build -t <image_name>:<version> -f <Dockerfile> .`
`e.g. $ sudo docker build -t synopsys_dc:X-2020.4 -f Dockerfile_Synopsys_DC .`
  - Remove intermediate image created during building an image.
```bash
$ sudo docker images    # find a tag of the intermediate image
$ sudo docker rmi <image_tag_you_want_to_remove>
```

  - Example container launching command
    - You should pass environment variable regarding your license server
```bash
$ sudo docker run --rm -it -e LM_LICENSE_FILE="<port>@<license_server>" \
                   -env="DISPLAY" \
                   <image_name> [<command>]
```

## Vendor specific regardings

### Synopsys

 - Requires following jobs to be run within Ubuntu (14.04) environment
```bash
$ sudo apt install csh libxss1 libsm6 libice6 libxft2 libjpeg62 libtiff5 libmng2 libpng12-0
# WORKAROUND link old library filenames with newer version
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/x86_64-linux-gnu/libtiff.so.3
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1
```

### Cadence

 - Requires following packages
```bash
$ sudo apt install openjdk-6-jre  # for installer
$ sudo dpkg --add-architecture i386
$ sudo apt libxtst6:i386 libxext6:i386 libxi6:i386 ksh csh \
```

 - define below envvar to execute 64-bit binary
`$ export CDS_AUTO_64BIT=ALL`

