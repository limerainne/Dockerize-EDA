#!/bin/bash

# NOTE define below envvars for specific tool and its vendor!

## example for Synopsys
INSTALLER_DIR=installer_v3.2

TOOL_NAME=syn
TOOL_VER=vL-2016.03-SP5-5
# NOTICE for first 'v' in tool version string
## end of for Synopsys

## or for Cadence
#INSTALLER_DIR=InstallScape
#
#TOOL_NAME=INCISIVE
#TOOL_VER=15
## end of for Cadence

PACKAGE_ROOT=/export/installer/


# create mount point for installer / actual tool package directory
mkdir -p package/${INSTALLER_DIR}
mkdir -p package/${TOOL_NAME}_${TOOL_VER}

# WORKAROUND use bind mount to get installer without copying files
sudo mount --bind ${PACKAGE_ROOT}/${INSTALLER_DIR} package/${INSTALLER_DIR}
sudo mount --bind ${PACKAGE_ROOT}/${TOOL_NAME}_${TOOL_VER} package/${TOOL_NAME}_${TOOL_VER}

# after creating images, be sure to unmount above directories!
