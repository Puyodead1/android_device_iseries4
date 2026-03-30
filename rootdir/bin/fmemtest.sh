#!/system/bin/sh
# Copyright (c) 2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

testcount=`getprop persist.vendor.memtester.count`
timeout=`getprop persist.vendor.memtester.timeout`
testsize=`getprop persist.vendor.memtester.size`
feature=`getprop ro.vendor.oem.hw.feature`
log_dir=/data/memtester
wake_lock_file=/sys/power/wake_lock

# Avoid entering deep sleep
echo "oem" >> $wake_lock_file

#Try to stop flow log record
setprop persist.vendor.memtester.logrecord "0"

if [ "$testcount" -eq "" ]; then
    testcount=1
    setprop persist.vendor.memtester.count $testcount
fi
log_index=$testcount

#default timeout 8 hours
if [ "$timeout" -eq "" ] || [ "$timeout" -eq "0" ]; then
    timeout=28800
fi

if [ "$testsize" -eq "" ] || [ "$timeout" -eq "0" ]; then
    testsize="2G"
fi

if [ ! -d $log_dir ];then
  mkdir $log_dir > /dev/null 2>&1
else
  echo "log dir already exist"
  if [ "$testcount" -eq "1" ];then
    rm -rf $log_dir/*
  fi
fi

#check pay and cuLED
cuRedLED="false"
feature=`getprop ro.vendor.oem.hw.feature`
paycheck=$(echo $feature | grep "pay")
if [ "$paycheck" != "" ]; then
  echo "pay exist"
  cuRedLED="true"
fi

if [ "$cuRedLED" == "false" ]; then
  cucheck=$(echo $feature | grep "cuLED")
  if [ "$cucheck" != "" ]; then
    cuRedLED="true"
  fi
fi

if [ "$cuRedLED" == "true" ]; then
  blinkled="/sys/class/leds/f_red/trigger"
  testled="/sys/class/leds/f_red/test"
else
  blinkled="/sys/class/leds/i_orange/trigger"
  testled="/sys/class/leds/i_orange/test"
fi

function test_exit()
{
    setprop persist.vendor.memtester.result "$test_result"
    setprop persist.vendor.memtester.logrecord "0"
    setprop persist.vendor.memtester.start "0"
    test_end_time=`date`
    echo "$test_start_time: Test end with result: $test_result" >> $log_dir/memtester_log.txt
    exit
}

## record log
test_start_time=`date`
echo "\n$test_start_time: The $testcount test start" >> $log_dir/memtester_log.txt

##check ramdump
log_time=`date`
echo "$log_time: check ramdump" >> $log_dir/memtester_log.txt
read_ramdump >> $log_dir/memtester_log.txt
ramdump_result=$?

#echo "check ramdump result $ramdump_result"
if [ "$ramdump_result" -ne "254" ]; then
    ##echo "Device crashed"
    log_time=`date`
    echo "$log_time: Device crashed" >> $log_dir/memtester_log.txt
    if [ "$testcount" -gt "1" ]; then
        echo "Device crashed after memtester, test fail"
        echo "$log_time: Device crashed after memtester, test fail" >> $log_dir/memtester_log.txt
        test_result="failed"
        test_exit
    fi
else
    echo "$log_time: check ramdump result $ramdump_result, no ramdump" >> $log_dir/memtester_log.txt
fi

## check result for last
log_time=`date`
if [ "$testcount" -gt "1" ]; then
    precheck_result=`getprop persist.vendor.memtester.result`
    echo "$log_time: precheck_result: $precheck_result" >> $log_dir/memtester_log.txt
    if [ "$precheck_result" == "done" ]; then
        echo "$log_time: Memtester success at last boot up" >> $log_dir/memtester_log.txt
        test_result="done"
        test_exit
    elif [ "$precheck_result" == "failed" ]; then
        echo "$log_time: Memtester failed at last boot up" >> $log_dir/memtester_log.txt
        test_result="failed"
        test_exit
    fi
fi

#sleep 20s for system enter idle
sleep 20

#blink LED
echo "timer" > $blinkled
echo  1 > $testled

#start test flow log record
setprop persist.vendor.memtester.logrecord "1"
sleep 1

#update test count
testcount=$(($testcount+1))
setprop persist.vendor.memtester.count $testcount

#start memtester( 8h=28800s)
log_time=`date`
echo "$log_time: test time out: $timeout seconds; test size: $testsize" >> $log_dir/memtester_log.txt
setprop persist.vendor.memtester.result "clear"
nohup memtester -t $timeout $testsize &

#sleep timeout to check result
sleep $timeout
sleep 5

#check persist.vendor.memtester.result
test_result=`getprop persist.vendor.memtester.result`

logcat -d -b kernel > $log_dir/kernel_$log_index.txt

log_time=`date`
if [ "$test_result" == "done" ]; then
    echo "$log_time: Memtester success" >> $log_dir/memtester_log.txt
    test_result="done"
elif [ "$test_result" == "timeout" ]; then
    echo "$log_time: Memtester timeout, test sucess" >> $log_dir/memtester_log.txt
    test_result="done"
elif [ "$test_result" == "clear" ]; then
    echo "$log_time: Memtester start failed, test fail" >> $log_dir/memtester_log.txt
    test_result="failed"
elif [ "$test_result" == "failed" ]; then
    echo "$log_time: Memtester found error, test fail" >> $log_dir/memtester_log.txt
    test_result="failed"
elif [ "$test_result" == "ongoing" ]; then
    echo "$log_time: Memtester is ongoing after time out, test fail" >> $log_dir/memtester_log.txt
    test_result="failed"
fi

echo  0 > $testled
echo "none" > $blinkled
qvar_access set_var permissive Qoff
setenforce 1

test_exit


