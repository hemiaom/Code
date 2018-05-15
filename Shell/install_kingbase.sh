#!/bin/bash

log_info=scutech:dingjia
basearch=`arch`
local_pkgs=/root/pkgs
path=/opt/Kingbase/ES/V7

#更新源

function update_resources(){
    cd /etc/yum.repos.d
    mkdir repo
    mv *.repo repo/
    os_version=`cat /etc/redhat-release | awk '{print $7}' | sed 's/\.//g'`
    cat >/etc/yum.repos.d/scutech.repo<<EOF
[rhel$os_version]
name=rhel$os_version
baseurl=http://192.168.82.29/yum/rhel$os_version/$basearch/Server
enabled=1
gpgcheck=0 
EOF
yum clean all
yum update
}

#下载数据库安装包和许可证

function download_pkgs(){
    test -z `rpm -qa|grep lftp` && yum -y install lftp
    pkg_url=192.168.88.10/software/databases/kingbase/
    ftp_url=ftp://$log_info@$pkg_url
    pkg=`lftp -c "open $ftp_url; ls -1 *Linux*"`
    echo "all versions:"
    for s in ${pkg[@]}
    do
       echo $s | grep $basearch | cut -d "-" -f 2
    done
    echo -n "select the version:" 
    read version
    license_ver=`echo $version | cut -d "." -f 1`
    lftp -c "open $ftp_url; mget *$version*Linux-$basearch*; mget license*$license_ver*" && echo "$version pkg and license$license_ver download successful"
}

#解压安装包

function headle_pkgs(){
   [ -d $local_pkgs ] || mkdir $local_pkgs
   mv kdb* license* -t $local_pkgs
   cd $local_pkgs
   ls
   test -z `rpm -qa|grep unzip` && yum -y install unzip
   unzip kdb*.zip
   chmod 777 -R setup
}

#安装数据库

function install_db(){
   test -z `rpm -qa|grep expect` && yum -y install expect
#   useradd dbackup
#   echo 'dingjia' | passwd --stdin dbackup
#   mv $local_pkgs /home/dbackup 
   license=`echo /home/dbackup/$(basename ${local_pkgs})/license*`
   [ -d $path ] || mkdir -p $path
   chmod 777 -R $path
   cat >/home/dbackup/$(basename ${local_pkgs})/auto_installdb.py<<EOF
#!/usr/bin/expect
spawn su - dbackup
set timeout 600
expect "dbackup"
send "cd /home/dbackup/$(basename ${local_pkgs})\r"
expect "$(basename ${local_pkgs})"
send "sh setup.sh -i console\r"
expect "Welcome"
send "\r"
expect "License Agreement"
send "\r"
expect "2. LIMITATIONS AND OTHER RIGHT"
send "\r"
expect "EXPORT LIMITATION."
send "\r"
expect "3. UPGRADES."
send "\r"
expect "4. INTELLECTUAL PROPERTY."
send "\r"
expect "7. CONFIDENTIALITY."
send "\r"
expect "1. LIMITED WARRANTY."
send "\r"
expect "2. LIMITATION OF LIABILITY"
send "\r"
expect "DO YOU ACCEPT THE TERMS OF THIS LICENSE AGREEMENT? (Y/N):"
send "Y\r"
expect "ENTER THE NUMBER FOR THE INSTALL SET, OR PRESS <ENTER> TO ACCEPT THE DEFAULT"
send "1\r"
expect "Dependence Check"
send "\r"
expect "File Path"
send "$license\r"
expect "Enter an absolute path, or press <ENTER> to accept the default:"
send "\r"
expect "PRESS <ENTER> TO CONTINUE:"
send "\r"
expect "PRESS <ENTER> TO INSTALL:"
send "\r"
expect "Username (DEFAULT: krms):"
send "\r"
expect "Password (DEFAULT: krms):"
send "\r"
expect "Confirm Password (DEFAULT: krms):"
send "\r"
expect "PRESS <ENTER> TO CONTINUE:"
send "\r"
expect "Please select the database initialization method"
send "2\r"
expect "Please press <ENTER> to exit the installer.:"
send "\r"
send "exit\r"
expect eof
EOF
   chmod 777 /home/dbackup/$(basename ${local_pkgs})/auto_installdb.py
}
#install_db

#update_resources
download_pkgs
#headle_pkgs
