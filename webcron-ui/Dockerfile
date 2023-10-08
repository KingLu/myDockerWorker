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

## 设置时区
ENV TZ=Asia/Shanghai
RUN apt-get update --fix-missing && apt-get install -y unzip tzdata rsyslog &&\
    clean-layer.sh
RUN echo "${TZ}" > /etc/timezone \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
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


## 安装selenium
RUN \
    pip install -U selenium  &&\
    clean-layer.sh


#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Chrome Launch Script Wrapper
#=================================
COPY scripts/wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION
RUN if [ -z "$CHROME_DRIVER_VERSION" ]; \
  then CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && CHROME_DRIVER_VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"); \
  fi \
  && echo "Using chromedriver version: "$CHROME_DRIVER_VERSION \
  && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
  && rm -rf /opt/selenium/chromedriver \
  && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/chromedriver_linux64.zip \
  && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
  && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver  

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["supervisord", "-c", "/etc/supervisord.conf"]