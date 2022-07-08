# docker run -d -p 8000:8000 u2509/webcron-ui:base
#docker build -t u2509/webcron-ui:base .

FROM continuumio/anaconda3:2022.05


ARG DEBIAN_FRONTEND=noninteractive

COPY scripts/clean_layer.sh /usr/bin/clean-layer.sh
RUN \    
    chmod 755 /usr/bin/clean-layer.sh 

RUN \
    apt-get update &&\  
    apt-get install -y locales &&\
    sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen &&\
    locale-gen &&\
    clean-layer.sh

ENV LANG zh_CN.UTF-8


RUN apt-get update --fix-missing && apt-get install -y wget curl vim cron supervisor\
    git subversion &&\
    clean-layer.sh

    
RUN apt-get update --fix-missing && apt-get install -y  gcc mono-mcs && \
    clean-layer.sh

# RUN apt-get update --fix-missing && apt-get install -y build-essential python3-dev &&\
#     clean-layer.sh  

RUN \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install -y nodejs &&\
    clean-layer.sh


ENV TZ=Asia/Shanghai
RUN apt-get update --fix-missing && apt-get install -y unzip tzdata rsyslog &&\
    clean-layer.sh
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata    

## 安装crontab-ui
ENV   CRON_PATH /etc/crontabs

RUN   mkdir /crontab-ui; mkdir $CRON_PATH;touch $CRON_PATH/root; chmod +x $CRON_PATH/root

WORKDIR /crontab-ui

LABEL maintainer "@U2509"
LABEL description "Crontab-UI docker base on anaconda3"


COPY supervisord.conf /etc/supervisord.conf
COPY crontab-ui/ /crontab-ui
RUN   npm install &&\
    clean-layer.sh

## 安装open JDK 11
RUN apt-get update --fix-missing && apt-get install -y default-jdk &&\   
    clean-layer.sh

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
