#!/vendor/bin/sh

adbd_status=`getprop init.svc.adbd`
if [ "$adbd_status" -eq "running" ]; then
    setprop vendor.setting.restart.adbd "true"
fi



