#!/bin/bash

HADOOP_PRFIX=${HADOOP_PRFIX:-"/opt/hadoop-1.2.1"}
NAMENODE_IP=${NAMENODE_IP:-"0.0.0.0"}

echo "export JAVA_HOME=/usr/lib/jvm/java-1.7-openjdk" >> $HADOOP_PRFIX/conf/hadoop-env.sh

cat > $HADOOP_PRFIX/conf/core-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
 <name>fs.default.name</name>
  <value>hdfs://$NAMENODE_IP:49000</value>
</property>
<property>
  <name>hadoop.tmp.dir</name>
 <value>/opt/hdfs_name/var</value>
</property>
</configuration>
EOF

cat >$HADOOP_PRFIX/conf/hdfs-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
<name>dfs.name.dir</name>
<value>/opt/hdfs_name/name1,/opt/hdfs_name/name2</value>
<description></description>
</property>
<property>
<name>dfs.data.dir</name>
<value>/opt/hdfs_data/data1,/opt/hdfs_data/data2</value>
<description></description>
</property>
<property>
<name>dfs.replication</name>
<value>2</value>
</property>
</configuration>
EOF

if [ "$1"x = "namenode"x ];then
    echo "Start NameNode"
    if [ ! -d "/opt/hdfs_name/name1" ];then
        echo "Formatting namenode"
        $HADOOP_PRFIX/bin/hadoop namenode -format
    fi
    $HADOOP_PRFIX/bin/hadoop-daemon.sh start namenode
elif [ "$1"x = "datanode"x ];then
    echo "Start DataNode"
    $HADOOP_PRFIX/bin/hadoop-daemon.sh start datanode
fi

# TODO: if namenode/datanode down, exit.
while true; do sleep 1000; done
