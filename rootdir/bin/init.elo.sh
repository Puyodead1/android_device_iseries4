#!/vendor/bin/sh

LOG_TAG="init-elo-sh"

logi() {
  /vendor/bin/log -t "$LOG_TAG" -p i "$1"
}

loge() {
  /vendor/bin/log -t "$LOG_TAG" -p e "$1"
}

get_value() {
  if [ "$1" = camera_version ]; then
    setprop sys.camera.out ""
    file_value=`SONIXFW_Update_tool -FWVersion 0C45 6512`
    setprop sys.camera.out "${file_value}"
    logi "setprop sys.camera.out ${file_value}"
  fi
}

set_pwrusb_boost() {
  pwrusb_ctrl_path=`find /sys/bus/i2c/devices/7-002c/pwrusb_boost_ctl`
  logi "pwrusb_ctrl_path = ${pwrusb_ctrl_path}"
  boost_out=`getprop sys.usb.boost.mode.change`
  echo "$boost_out" > ${pwrusb_ctrl_path}
  logi "write $boost_out > ${pwrusb_ctrl_path}"
  boost_in=`cat ${pwrusb_ctrl_path}`
  setprop persist.sys.usb.boost.mode ${boost_in}
  logi "setprop persist.sys.usb.boost.mode ${boost_in}"
}

set_eth_duplex() {
  ethernet_ctl_path=`find /sys/class/net/eth0/ethernet_duplex_set`
  logi "ethernet_ctl_path = ${ethernet_ctl_path}"
  duplex_out=`getprop vendor.sys.eth.link.mode.change`
  echo "$duplex_out" > ${ethernet_ctl_path}
  logi "write $duplex_out > ${ethernet_ctl_path}"
  speed_in=`cat /sys/class/net/eth0/speed`
  duplex_in = `cat /sys/class/net/eth0/duplex`
  logi "speed_in ${speed_in}"
  logi "duplex_in ${duplex_in}"
}


#####################################################
#                       main                        #
#####################################################
if [ "$1" = get_camera_version ]; then
    get_value camera_version
elif [ "$1" = set_pwrusb_boost ]; then
    set_pwrusb_boost
elif [ "$1" = set_eth_duplex ]; then
    set_eth_duplex
fi

