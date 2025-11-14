#!/bin/bash

fileToChange=/lib/systemd/system/systemd-logind.service

sed -i 's/^IPAddressDeny=any/#IPAddressDeny=any/' $fileToChange

grep IPAddressDeny $fileToChange

echo "You may need to run this command: "
echo "  systemctl daemon-reload"

