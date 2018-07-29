#!/bin/bash

FILE='/etc/sysconfig/network-scripts/ifcfg-ens160'

cat <<EOM >$FILE
TYPE="Ethernet"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens160"
UUID="1adc54be-bb9b-4172-830f-bf5d785de735"
DEVICE="ens160"
ONBOOT="yes"
PREFIX="20"
GATEWAY="10.0.1.1"
DNS1="10.0.1.1"
DNS2="8.8.8.8"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
IPV6_PRIVACY="no"
EOM

systemctl restart network