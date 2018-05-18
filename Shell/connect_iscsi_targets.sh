#!/bin/bash
#连接iscsi targets
function usage()
{
  echo "Usage:`basename $0` [-a ip] [-c] [-d]
       -a ip         - ip address
       -c            - connect targets
       -d            - dicconnect targets
  "
 
}

function contarget()
{
  target=(`iscsiadm -m discovery -t sendtargets -p ${ip} | awk '{print $2}'`)
  for((i=0;i<${#target[@]};i++));do 
  iscsiadm -m node -T ${target[${i}]} --login
  done
  lsscsi -g -t
}

function disctarget()
{
  target=(`iscsiadm -m discovery -t sendtargets -p ${ip} | awk '{print $2}'`)
  for((i=0;i<${#target[@]};i++));do
  iscsiadm -m node -T ${target[${i}]} --logout
  done
  lsscsi -g -t
}
[ $# -eq 0 ] && usage

while getopts "a:cd" opt;do
  case $opt in
    a)
      ip=$OPTARG
      ;;
    c)
      contarget
      ;;
    d)
      disctarget
      ;;
    \?)
      usage
      ;;
  esac
done

