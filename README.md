# [WIP] Dockerize scripts for commercial EDA tools

Here is the `Dockerfile`s to dockerize popular [EDA (Electronic Design Automation)](https://en.wikipedia.org/wiki/Electronic_design_automation) tools!

With docker images made from these `Dockerfiles`, we could do:
 * Build/test your design on the cloud server (but here comes a license issue :) )
 * Maintain tools with as many different version as you want without difficulties
 * Provide tools for you or your peer's desktop computer regardless of which OS you are using
 * [Continuous Integration (CI)](https://en.wikipedia.org/wiki/Continuous_integration) for your design
 * and much more!

> Of course, most things listed above could be done without Docker and meaningless job made by me :)    
> I don't know dockering tools is useful or not...

## Packages tried to dockerize
 - Synosys
   - Design Compiler (DC)
   - IC Compiler (ICC)
   - VCS (RTL Simulator) (N-2017; w/ Ubuntu 16.04)
   - HSPICE (N-2017; for J-2014 `netbase` package is also required ([#6][i6]))
 - Cadence
   - Incisive (NCSim)
   - Virtuoso (IC)

## CAVEAT
  - You should NOT upload an image containing commercial tool to PUBLIC docker registry! ;-)

  - Intermediate images are not removed automatically, you have to remove by yourself for now. (see below)

  - X11 forwarding with host was not prepared. In other words, with this image you cannot open GUI windows out-of-the-box. (See [#3][i3])

  - How can we run docker container with unpriviledged permission? In other words, can this image be used similar to desktop applications?
    - Currently, I did not prepare to drop root priviledge in `Dockerfile`s
    - [Singularity](https://www.sylabs.io) could be a solution [#5][i5]

## Prerequisites
  - Docker 17.05+ (this script uses multi-stage build feature)
  - Installer and installation package of the tool you want to dockerize
     - This repository consists of just `Dockerfile`s, not of actual images or installer packages

## Generating an image
  
  - Clone this repository to your workstation.
  - Copy (or bind mount) installer and installation package to the subdirectory
     - Refer to shell scripts for bind-mounting installation files from other path. Bind mount was used only for avoiding copy installation package to working path
  - modify dockerfile to match with your tool version, your requirements, etc.
  - Execute below command to create an image.  
```bash
$ sudo docker build -t <image_name>:<version> -f <Dockerfile> .
e.g. $ sudo docker build -t synopsys_dc:X-2020.4 -f Dockerfile_Synopsys_DC .
```
  - You can manually remove intermediate images created during building an image.
```bash
$ sudo docker images    # find a tag of the intermediate image
$ sudo docker rmi <image_tag_you_want_to_remove>

or

$ docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
```

## Launch a container
  - Example command to run a container
    - You should pass `LM_LICENSE_FILE` environment variable regarding your license server
    - Consider bind mount your user directory
```bash
$ sudo docker run --rm -it -e LM_LICENSE_FILE="<port>@<license_server>" \
                   <image_name> [<command>]
```
  - To run a container with GUI (X11) enabled, see [#3][i3].

## Vendor specific requirements

### Synopsys

 - Requires following jobs to be run within Ubuntu (14.04) environment
```bash
$ sudo apt install csh libxss1 libsm6 libice6 libxft2 libjpeg62 libtiff5 libmng2 libpng12-0
# WORKAROUND link old library filenames with newer version
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/x86_64-linux-gnu/libtiff.so.3
$ sudo ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1
```

 - Change default shell from `dash` to `bash` for avoiding shell script compatibility issues
 ```bash
 $ sudo update-alternatives --install /bin/sh sh /bin/bash 20
 ```

 - Ubuntu 18.04 requires additional treatments, because `libpng12-0` package was removed from that version
   - Manually download and install `libpng12-0` package, or add source of older releases and install package from that source like below:
```bash
$ sudo 'echo "deb http://security.ubuntu.com/ubuntu xenial-security main" >> /etc/apt/sources.list'
$ sudo apt update
$ sudo apt install -y -t xenial libpng12-0
```

#### HSPICE
 - Requires `libxml2` also
 
##### J-2014
 - Requires `netbase` package, which has `/etc/protocols` file

#### VCS
 - Additionally required packages:
   - `dc`
   - gcc/g++ compiler
     - In Debian/Ubuntu, you can do that by simply installing `build-essential` package (with unnecessary more packages ;-( )

 - Define below environment variables
```bash
$ export VCS_HOME=<path_to_vcs>
$ export VCS_TARGET_ARCH="amd64"
```

 - Set alias for `vcs` command. Below example is for Bash shell:    
`$ alias vcs="vcs -full64"`
   - Unfortunately, `VCS_TARGET_ARCH` was not fully effective
   - This was not implemented in VCS `Dockerfile` for now    

### Cadence

 - Requires following packages
```bash
$ sudo apt install openjdk-6-jre  # for installer
$ sudo dpkg --add-architecture i386
$ sudo apt libxtst6:i386 libxext6:i386 libxi6:i386 ksh csh \
```

 - Define below environment variable to execute 64-bit binary  
`$ export CDS_AUTO_64BIT=ALL`

 - (Virtuoso) Define below environment variable regarding inside `<path/to/virtuoso>/share/oa/lib/`  
`$ export OA_UNSUPPORTED_PLAT "linux_rhel50_gcc48x"`

### Mentor

 - Have to mimic OS vendor and version as Redhat 7.0
   - Refer to the [Patch file](https://github.com/limerainne/Dockerize-EDA/blob/master/patches/mentor_calibre_os_as_rh7.patch)

[i3]: https://github.com/limerainne/Dockerize-EDA/issues/3
[i5]: https://github.com/limerainne/Dockerize-EDA/issues/5
[i6]: https://github.com/limerainne/Dockerize-EDA/issues/6
