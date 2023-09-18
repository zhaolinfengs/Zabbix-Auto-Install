#!/usr/bin/expect

#登录数据库 
spawn mysql -uroot -p 
expect {
    "password:" { send "redhat\n" }
}
##创建用户
expect "]>" { send "show databases;\n"}
expect "]>" { send "create database zabbix character set utf8 collate utf8_bin;\n"}
expect "]>" { send "create user zabbix@localhost identified by 'password';\n"}
expect "]>" { send "grant all privileges on zabbix.* to zabbix@localhost;\n"}
expect "]>" { send "flush privileges;\n"}
expect "]>" { send "grant all privileges on zabbix.* to zabbix@localhost;\n"}
expect "]>" { send "flush privileges;\n"}
expect "]>" { send "show databases;\n"}
expect "]>" { send "exit;\n"}
