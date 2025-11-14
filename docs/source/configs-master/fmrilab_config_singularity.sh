#!/bin/bash

localstatedir=/localstatedir

echo "Creating the localdestdir for singularity in host $HOST"
mkdir -vp \
${localstatedir}/singularity/mnt \
${localstatedir}/singularity/mnt/container \
${localstatedir}/singularity/mnt/final \
${localstatedir}/singularity/mnt/overlay \
${localstatedir}/singularity/mnt/session
