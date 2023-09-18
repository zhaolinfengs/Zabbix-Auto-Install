#!/bin/bash
##准备工作
#0.0禁用防火墙（如果不能关掉只能放通可以修改以下禁用操作）
systemctl stop firewalld 
systemctl disable firewalld
systemctl status firewalld
##0.1禁用selinux
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

##下载镜像源
rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sed -i 's#http://repo.zabbix.com#https://mirrors.aliyun.com/zabbix#' /etc/yum.repos.d/zabbix.repo
yum clean all 
yum makecache
echo "01下载zabbix软件镜像源完成" >> /var/log/zabbix-install.log

##配置ntp
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install -y ntpdate
ntpdate ntp.aliyun.com
echo "02配置NTP时钟完成" >> /var/log/zabbix-install.log

##安装zabbix server、web前端、agent
yum install zabbix-server-mysql zabbix-agent  -y 
echo "03安装zabbix-server完成" >> /var/log/zabbix-install.log

##安装软件源
yum install centos-release-scl  -y 
echo "04安装软件源完成" >> /var/log/zabbix-install.log

##替换zabbix的软件源文件
sed -i "s/enabled=0/enabled=1/g" /etc/yum.repos.d/zabbix.repo
echo "05替换zabbix软件源" >> /var/log/zabbix-install.log

##安装隔离环境的包
yum install zabbix-web-mysql-scl zabbix-apache-conf-scl -y
echo "06安装隔离环境的包" >> /var/log/zabbix-install.log

##安装数据库
yum install mariadb-server -y
echo "07数据库安装完成" >> /var/log/zabbix-install.log

##配置expect环境
yum install -y expect
echo "08配置expect环境成功" >> /var/log/zabbix-install.log

##配置数据库并初始化
systemctl enable --now mariadb
./database.sh
echo "09数据库初始化完成" >> /var/log/zabbix-install.log

##创建数据库密码以及用户
./dbuser.sh
echo "10数据库用户配置完成" >> /var/log/zabbix-install.log

##导入zabbix数据库
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -ppassword zabbix
echo "11导入zabbix数据库" >> /var/log/zabbix-install.log

##修改zabbix-server配置文件，修改数据库连接密码
sed -i "s/# DBPassword=/DBPassword=password/g" /etc/zabbix/zabbix_server.conf
echo "12修改数据库连接密码" >> /var/log/zabbix-install.log

##修改php时区配置
sed -i "s/; //g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i "s/Europe/Asia/g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sed -i "s/Riga/Shanghai/g" /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
echo "13修改php时区配置" >> /var/log/zabbix-install.log

##启动zabbix
systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
echo "14启动zabbix" >> /var/log/zabbix-install.log


