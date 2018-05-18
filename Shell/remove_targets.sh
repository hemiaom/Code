#!/bin/bash

#清空zfs环境

SERVER_IP=$2
SERVER_PORT=50305
function usage(){
	echo "Usage:`basename $0` [-i SERVER_IP]
	-i SERVER_IP - Please input the SERVER_IP.
	" 
}
function remove_pools(){
	curl $SERVER_IP:$SERVER_PORT/d2/r/storages/pools>pools.json
	pools=`grep -Po 'pool_uuid[" :]+\K[^"]+' pools.json`
	for pool in $pools
	  do
		curl -D scutech_cookies --data "{\"username\":\"admin\",\"password\":\"admin\"}" $SERVER_IP:$SERVER_PORT/d2/r/v2/user/logon  -H 'Content-Type: application/json' 
		curl -I -X DELETE  $SERVER_IP:${SERVER_PORT}DELETE/d2/r/storages/pools?uuid=$pool -b scutech_cookies
	  done
	rm -rf pools.json
	rm -rf scutech_cookies
}
function uninstall_dbackup(){
	[ `dpkg -l|grep dbackup | wc -l` -ne 0 ] && dpkg -P `dpkg -l|grep dbackup`
	rm -rf /var/opt/scutech
	rm -rf /etc/opt/scutech
	rm -rf /var/lib/dbackup3
	rm -rf /var/log/dbackup3
    rm -rf /var/log/scutech
	rm -rf /etc/default/dbackup3*
}
function remove_mysql(){
	str_pid=`lsof /infokist/`
	test "$str_pid" && dpkg -P `dpkg -l|grep mysql | awk '{print $2}'`
} 
function remove_main(){
	remove_pools
    uninstall_dbackup
	service target stop
	remove_mysql
	zpool destroy infokist
	cat>/etc/target/lio_start.sh<<EOF
mkdir /sys/kernel/config/target/iscsi
#### iSCSI Discovery authentication information
EOF
	cat >/etc/target/qla2xxx_start.sh<<EOF
modprobe tcm_qla2xxx
mkdir /sys/kernel/config/target/qla2xxx
#### qla2xxx Target Ports
#### Attributes for qla2xxx Target Portal Group
EOF
	cat >/etc/target/tcm_start.sh<<EOF
modprobe target_core_mod
#### ALUA Logical Unit Groups
#### Parameters for TCM subsystem plugin storage object reference
EOF
	cat /dev/null>/etc/zfs/zpool.cache
	rm -rf /etc/target/backup/*

}
[ $# -eq 0 ] && usage
[ $# -ne 0 ] && remove_main
