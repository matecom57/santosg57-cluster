#/bin/bash

if [[ `hostname` == "tesla" ]]
then

echo ""
echo ""
echo "Modifying cell name in /etc/systemd/system/sgemaster.service"
echo ""
echo ""

sed -i 's/\/opt\/sge\/default/\/opt\/sge\/fmrilab/g' /etc/systemd/system/sgemaster.service

echo "The file now contains:"
echo ""
cat /etc/systemd/system/sgemaster.service


echo "Reloading service"
systemctl daemon-reload
systemctl start sgemaster.service
systemctl status sgemaster.service

else

echo ""
echo ""
echo "Modifying cell name in /etc/systemd/system/sgeexecd.service"
echo ""
echo ""

sed -i 's/\/opt\/sge\/default/\/opt\/sge\/fmrilab/g' /etc/systemd/system/sgeexecd.service

echo "The file now contains:"
echo ""
cat /etc/systemd/system/sgeexecd.service


echo "Reloading service"
systemctl daemon-reload
systemctl start sgeexecd.service
systemctl status sgeexecd.service
fi


source /opt/sge/fmrilab/common/settings.sh
