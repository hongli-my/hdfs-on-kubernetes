## hdfs on kubernetes

### TODO

1. check namenode/datanode/journalnode status
2. monut volume for tmp/journalnode

### Warnings

docker 默认的iptable 规则, 会修改源ip, 导致namenode 收到的地址会宿主机的地址(不使用hostNet), 无法正常工作
```
iptables -t nat -A POSTROUTING -s $docker0IP  ! -o docker0 -j MASQUERADE
```
