#!/bin/bash

set -e

useradd solr

wget https://archive.apache.org/dist/lucene/solr/5.5.1/solr-5.5.1.tgz
tar xzf solr-5.5.1.tgz

bash solr-5.5.1/bin/install_solr_service.sh solr-5.5.1.tgz
chown solr:solr /var/solr -R

bash solr-5.5.1/bin/install_solr_service.sh solr-5.5.1.tgz -s solr2 -p 8984

cd /opt
wget http://mirror.vorboss.net/apache/zookeeper/current/zookeeper-3.4.8.tar.gz
tar xzf zookeeper-3.4.8.tar.gz

cp -R /opt/zookeeper-3.4.8/ /opt/zookeeper-3.4.8-2
cp -R /opt/zookeeper-3.4.8/ /opt/zookeeper-3.4.8-3
ln -s /opt/zookeeper-3.4.8/ /opt/zookeeper
ln -s /opt/zookeeper-3.4.8-2/ /opt/zookeeper2
ln -s /opt/zookeeper-3.4.8-3/ /opt/zookeeper3

cp /cloud-conf/zkrun /usr/local/sbin/zkrun
cp /cloud-conf/zkrun2 /usr/local/sbin/zkrun2
cp /cloud-conf/zkrun3 /usr/local/sbin/zkrun3
chmod +x /usr/local/sbin/zkru*

ln -s /usr/local/sbin/zkrun /etc/init.d/zookeeper
ln -s /usr/local/sbin/zkrun2 /etc/init.d/zookeeper2
ln -s /usr/local/sbin/zkrun3 /etc/init.d/zookeeper3
chkconfig --add zookeeper
chkconfig --add zookeeper2
chkconfig --add zookeeper3
chkconfig zookeeper on
chkconfig zookeeper2 on
chkconfig zookeeper3 on

cp /cloud-conf/zoo.cfg /opt/zookeeper/conf/zoo.cfg 
cp /cloud-conf/zoo2.cfg /opt/zookeeper2/conf/zoo.cfg 
cp /cloud-conf/zoo3.cfg /opt/zookeeper3/conf/zoo.cfg 

mkdir -p /var/lib/zookeeperdata/1 mkdir -p /var/lib/zookeeperdata/2 mkdir -p /var/lib/zookeeperdata/3

echo 1 > /var/lib/zookeeperdata/1/myid
echo 2 > /var/lib/zookeeperdata/2/myid
echo 3 > /var/lib/zookeeperdata/3/myid

service zookeeper start
service zookeeper2 start
service zookeeper3 start

sed -i -e "s/\#ZK_HOST=\"\"/ZK_HOST=\"localhost:2181,localhost:2182,localhost:2183\"/g" /etc/default/solr.in.sh
sed -i -e "s/\#ZK_HOST=\"\"/ZK_HOST=\"localhost:2181,localhost:2182,localhost:2183\"/g" /etc/default/solr2.in.sh

service solr restart
service solr2 restart

bash /opt/solr/bin/solr create_collection -shards 2 -replicationFactor 2 -c product -d /opt/solr-5.5.1/server/solr/configsets/data_driven_schema_configs