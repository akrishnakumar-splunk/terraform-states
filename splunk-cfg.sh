#!/bin/bash

wget -O  /tmp/splunk-7.0.3-fa31da744b51-linux-2.6-x86_64.rpm https://www.splunk.com/page/download_track?file=7.0.3/linux/splunk-7.0.3-fa31da744b51-linux-2.6-x86_64.rpm&ac=&wget=true&name=wget&platform=Linux&architecture=x86_64&version=7.0.3&product=splunk&typed=release

yum install -y /tmp/splunk-7.0.3-fa31da744b51-linux-2.6-x86_64.rpm

/opt/splunk/bin/splunk start --answer-yes --no-prompt --accept-license

/opt/splunk/bin/splunk enable boot-start

/opt/splunk/bin/splunk stop