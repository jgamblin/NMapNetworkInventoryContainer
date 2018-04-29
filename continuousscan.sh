#!/bin/bash
TARGETS="192.168.1.0/24"
OPTIONS="-sV"

cd /inventory || return
python3 -m http.server 1337 &

while true; do
echo ''
echo '=================='
echo ''

echo ''
# Remove Old Gnmap
rm scan.gnmap
#Start Nmap:s
printf "nmap ${OPTIONS} ${TARGETS} -oG /inventory/scan.gnmap"
nmap $OPTIONS $TARGETS -oG /inventory/scan.gnmap
#Remove Old Data
rm data.csv
#Update Data:
cat scan.gnmap
./nmapcsv.sh scan.gnmap > data.csv


#2 Hour Count Down Between Scans
m=${1}-1
Floor () {
DIVIDEND=${1}
DIVISOR=${2}
RESULT=$(( ( ${DIVIDEND} - ( ${DIVIDEND} % ${DIVISOR}) )/${DIVISOR} ))
echo ${RESULT}
}

Timecount(){
s=7200
HOUR=$( Floor ${s} 60/60 )
s=$((${s}-(60*60*${HOUR})))
MIN=$( Floor ${s} 60 )
SEC=$((${s}-60*${MIN}))
while [ $HOUR -ge 0 ]; do
while [ $MIN -ge 0 ]; do
while [ $SEC -ge 0 ]; do
printf "Rescanning in %02d:%02d:%02d\033[0K\r" $HOUR $MIN $SEC
SEC=$((SEC-1))
sleep 1
done
SEC=59
MIN=$((MIN-1))
done
MIN=59
HOUR=$((HOUR-1))
done
}

Timecount $m

done
