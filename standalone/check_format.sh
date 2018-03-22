#!/bin/bash

function check_formt(){
    count=1
    while true
    do
        if [ $count -gt 5 ];then
            echo "fomat namenode tmp dir fail"
            exit 1
        fi
        if [ -d "$HDFS_TMP_DIR/dfs/name/current" ];then
            break
        fi
        $HADOOP_PRFIX/bin/hdfs namenode -format
        count=$(($count+1))
        sleep 2
    done
}

check_formt
