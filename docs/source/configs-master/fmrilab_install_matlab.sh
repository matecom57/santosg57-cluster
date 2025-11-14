#!/bin/bash

time rsync -avz --progress soporte@mansfield:/usr/local/MATLAB /usr/local/
ln -s /usr/local/MATLAB/R2022a/bin/matlab /usr/local/bin/matlab
chown -R soporte  /usr/local/MATLAB
chgrp -R fmriuser /usr/local/MATLAB
chmod -R g+rX     /usr/local/MATLAB

