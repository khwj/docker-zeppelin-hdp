#!/bin/bash

${ZEPPELIN_HOME}/bin/zeppelin-daemon.sh start
sleep 1
tail -F /var/log/zeppelin/*.log