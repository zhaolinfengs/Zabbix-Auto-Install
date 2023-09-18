#!/usr/bin/expect
##初始化数据库
spawn mysql_secure_installation
expect {
    "none):" { send "\n";exp_continue }   ##输入当前的root密码，初次回车即可
    "none):" { send "y\n";exp_continue }  ##是否配置root密码，输入y
    "password:" { send "redhat\n";exp_continue }  ##输入新密码
    "password:" { send "redhat\n";exp_continue }  ##输入新密码
    "n]" { send "y\n";exp_continue }    ##是否禁止匿名用户登录
    "n]" { send "n\n";exp_continue }    ##是否禁止root登录
    "n]" { send "y\n";exp_continue }    ##是否移除test表
    "n]" { send "y\n";exp_continue }    ##是否刷新权限表
}
