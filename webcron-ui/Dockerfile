# docker run -d -p 8000:8000 alseambusher/crontab-ui
#docker build -t u2509/webcron-ui:ubuntu .
FROM ubuntu:latest


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


RUN apt-get update --fix-missing && apt-get install -y wget curl vim cron \
    git subversion &&\
    clean-layer.sh

RUN apt-get update --fix-missing && apt-get install -y supervisor &&\   
    clean-layer.sh

RUN apt-get update --fix-missing && apt-get install -y python3 python3-pip &&\   
    clean-layer.sh

RUN \
    pip install -U pip setuptools &&\
    clean-layer.sh
    
RUN apt-get update --fix-missing && apt-get install -y build-essential python3-dev &&\
    clean-layer.sh  

RUN \
    curl -sL https://deb.nodesource.com/setup_lts.x | bash - &&\
    apt-get install -y nodejs &&\
    clean-layer.sh

RUN \
    npm install -g crontab-ui &&\
    clean-layer.sh   

ENV   CRON_PATH /etc/crontabs

RUN   mkdir $CRON_PATH;mkdir /crontab-ui; touch $CRON_PATH/root; chmod +x $CRON_PATH/root

WORKDIR /crontab-ui

LABEL maintainer "@alseambusher"
LABEL description "Crontab-UI docker"

COPY supervisord.conf /etc/supervisord.conf
COPY . /crontab-ui

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
