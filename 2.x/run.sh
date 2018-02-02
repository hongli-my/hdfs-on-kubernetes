#!/bin/bash


HADOOP_PRFIX=${HADOOP_PRFIX:-"/opt/hadoop-2.6.5"}
# zookeeper address
ZK_IP=${ZK_IP:-"datanode01:2181,datanode02:2181,datanode03:2181"}
HDFS_NAMESERVICE=${HDFS_NAMESERVICE:-"cluster1"}
NAMENODE1=${NAMENODE1:-"hdfs-0.hdfs-headless.default.svc.cluster.local"}
NAMENODE2=${NAMENODE2:-"hdfs-1.hdfs-headless.default.svc.cluster.local"}
JNODES_IPS=${JNODES_IPS:-"datanode01:8485;datanode02:8485;datanode03:8485"}

HOST=`hostname -s`
chown -R root:root $HADOOP_PRFIX
mkdir -p /opt/hdfs/{data,tmp,journaldata}

if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
else
    echo "Failed to extract ordinal from hostname $HOST"
    if [ "$1"x = "namenode"x ];then
        exit 1
    fi
fi

cat >> $HADOOP_PRFIX/etc/hadoop/hadoop-env.sh <<EOF
export  HADOOP_HOME=$HADOOP_PRFIX
export  HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export  HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib:\$HADOOP_COMMON_LIB_NATIVE_DIR"
EOF

cat > $HADOOP_PRFIX/etc/hadoop/core-site.xml <<EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://$HDFS_NAMESERVICE/</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/hdfs/tmp</value>
    </property>
    <property>
        <name>ha.zookeeper.quorum</name>
        <value>$ZK_IP</value>
    </property>
</configuration>
EOF

cat >$HADOOP_PRFIX/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
    <property>
        <name>dfs.nameservices</name>
        <value>$HDFS_NAMESERVICE</value>
    </property>
    <property>
        <name>dfs.ha.namenodes.$HDFS_NAMESERVICE</name>
        <value>nn1,nn2</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.$HDFS_NAMESERVICE.nn1</name>
        <value>$NAMENODE1:9000</value>
    </property>
    <property>
        <name>dfs.namenode.http-address.$HDFS_NAMESERVICE.nn1</name>
        <value>$NAMENODE1:50070</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.$HDFS_NAMESERVICE.nn2</name>
        <value>$NAMENODE2:9000</value>
    </property>
    <property>
        <name>dfs.namenode.http-address.$HDFS_NAMESERVICE.nn2</name>
        <value>$NAMENODE2:50070</value>
    </property>
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://$JNODES_IPS/$HDFS_NAMESERVICE</value>
    </property>
    <property>
        <name>dfs.journalnode.edits.dir</name>
        <value>/opt/hdfs/journaldata</value>
    </property>
    <property>
        <name>dfs.ha.automatic-failover.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.client.failover.proxy.provider.$HDFS_NAMESERVICE</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>
    <property>
        <name>dfs.ha.fencing.methods</name>
        <value>
            sshfence
            shell(/bin/true)
        </value>
    </property>
    <property>
        <name>dfs.ha.fencing.ssh.private-key-files</name>
        <value>/root/.ssh/id_rsa</value>
    </property>
    <property>
        <name>dfs.ha.fencing.ssh.connect-timeout</name>
        <value>30000</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///opt/hdfs/data</value>
        <description>Comma separated list of paths on the local filesystem of a DataNode where it should store its blocks.</description>
    </property>
    <property> 
        <name>dfs.journalnode.http-address</name> 
        <value>0.0.0.0:8480</value> 
    </property> 
    <property> 
        <name>dfs.journalnode.rpc-address</name> 
        <value>0.0.0.0:8485</value> 
    </property>
    <property>
        <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
        <value>false</value>
    </property>
</configuration>
EOF

function check_sync(){
    count=1
    while true
    do
        if [ $count -gt 5 ];then
            echo "nc -zv $1 $2 fail"
            exit 1
        fi
        nc -zv  $1 $2
        if [ $? -eq 0 ];then
            break
        fi
        count=$(($count+1))
        sleep 2
    done
    $HADOOP_PRFIX/bin/hdfs namenode -bootstrapStandby
}

function check_formt(){
    count=1
    while true
    do
        if [ $count -gt 5 ];then
            echo "fomat namenode tmp dir fail"
            exit 1
        fi
        if [ -d "/opt/hdfs/tmp/dfs/name/current" ];then
            break
        fi
        $HADOOP_PRFIX/bin/hdfs namenode -format
        count=$(($count+1))
        sleep 2
    done
}

# start JournalNode
if [ "$1"x = "journalnode"x ];then
    $HADOOP_PRFIX/sbin/hadoop-daemon.sh start journalnode
elif [ "$1"x = "datanode"x ];then
    $HADOOP_PRFIX/sbin/hadoop-daemon.sh start datanode
elif [ "$1"x = "namenode"x ];then
    # format zkfc on 01
    if [ $ORD -eq 0 ];then
        /check_path $ZK_IP /hadoop-ha/$HDFS_NAMESERVICE
        if [ $? -eq 0 ];then
            $HADOOP_PRFIX/bin/hdfs zkfc -formatZK
            check_formt
        else
            check_sync $NAMENODE2 9000
        fi
    fi
    if [ $ORD -eq 1 ];then
        check_sync $NAMENODE1 9000
    fi
    $HADOOP_PRFIX/sbin/hadoop-daemon.sh start zkfc
    $HADOOP_PRFIX/sbin/hadoop-daemon.sh start namenode
fi

# TODO: if namenode/datanode down, exit.
/usr/sbin/sshd -D
