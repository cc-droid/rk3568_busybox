#!/usr/bin/expect
spawn ftp 192.168.6.231
expect "Name"
send "root\r"
expect "Password"
send "rk3568\r"
expect "ftp>"
send "put $argv\r"
expect "ftp>"
send "bye\r"
interact
