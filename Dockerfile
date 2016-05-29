FROM centos:6
MAINTAINER Volkan Altan <volkanaltan@gmail.com>

RUN yum install -y \
  lsof \
  java-1.7.0-openjdk \
  java-1.7.0-openjdk-devel \
  system-config-services \
  wget

RUN mkdir -p /cloud-conf
ADD ./conf /cloud-conf

VOLUME ["conf"]

ADD scripts/install.sh /install.sh
RUN chmod 755 /install.sh

EXPOSE 8983 8984 2181 2182 2183

CMD ["/bin/bash", "/install.sh"]
