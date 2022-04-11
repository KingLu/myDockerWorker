# docker run -d -p 8000:8000 u2509/webcron-ui:ubuntu-20.04
#docker build -t u2509/webcron-ui:ubuntu-20.04 .
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

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
RUN apt-get update --fix-missing && apt-get install -y unzip tzdata &&\
    clean-layer.sh
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata    

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



#=========
# Firefox
#=========
ARG FIREFOX_VERSION=latest
RUN FIREFOX_DOWNLOAD_URL=$(if [ $FIREFOX_VERSION = "latest" ] || [ $FIREFOX_VERSION = "nightly-latest" ] || [ $FIREFOX_VERSION = "devedition-latest" ] || [ $FIREFOX_VERSION = "esr-latest" ]; then echo "https://download.mozilla.org/?product=firefox-$FIREFOX_VERSION-ssl&os=linux64&lang=en-US"; else echo "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2"; fi) \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox libavcodec-extra \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

#============
# GeckoDriver
#============
ARG GECKODRIVER_VERSION=latest
RUN GK_VERSION=$(if [ ${GECKODRIVER_VERSION:-latest} = "latest" ]; then echo "0.30.0"; else echo $GECKODRIVER_VERSION; fi) \
  && echo "Using GeckoDriver version: "$GK_VERSION \
  && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
  && rm -rf /opt/geckodriver \
  && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
  && rm /tmp/geckodriver.tar.gz \
  && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
  && chmod 755 /opt/geckodriver-$GK_VERSION \
  && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver


#============================================
# Microsoft Edge
#============================================
# can specify versions by EDGE_VERSION;
#  e.g. microsoft-edge-beta=88.0.692.0-1
#============================================
ARG EDGE_VERSION="microsoft-edge-stable"
RUN wget -q -O - https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && echo "deb https://packages.microsoft.com/repos/edge stable main" >> /etc/apt/sources.list.d/microsoft-edge.list \
  && apt-get update -qqy \
  && apt-get -qqy install ${EDGE_VERSION} \
  && rm /etc/apt/sources.list.d/microsoft-edge.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Edge Launch Script Wrapper
#=================================
COPY scripts/wrap_edge_binary /opt/bin/wrap_edge_binary
RUN /opt/bin/wrap_edge_binary

#============================================
# Edge webdriver
#============================================
# can specify versions by EDGE_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG EDGE_DRIVER_VERSION
RUN if [ -z "$EDGE_DRIVER_VERSION" ]; \
  then EDGE_MAJOR_VERSION=$(microsoft-edge --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && EDGE_DRIVER_VERSION=$(wget --no-verbose -O - "https://msedgedriver.azureedge.net/LATEST_RELEASE_${EDGE_MAJOR_VERSION}_LINUX" | tr -cd "\11\12\15\40-\176" | tr -d "\r"); \
  fi \
  && echo "Using msedgedriver version: "$EDGE_DRIVER_VERSION \
  && wget --no-verbose -O /tmp/msedgedriver_linux64.zip https://msedgedriver.azureedge.net/$EDGE_DRIVER_VERSION/edgedriver_linux64.zip \
  && rm -rf /opt/selenium/msedgedriver \
  && unzip /tmp/msedgedriver_linux64.zip -d /opt/selenium \
  && rm /tmp/msedgedriver_linux64.zip \
  && mv /opt/selenium/msedgedriver /opt/selenium/msedgedriver-$EDGE_DRIVER_VERSION \
  && chmod 755 /opt/selenium/msedgedriver-$EDGE_DRIVER_VERSION \
  && ln -fs /opt/selenium/msedgedriver-$EDGE_DRIVER_VERSION /usr/bin/msedgedriver

RUN  clean-layer.sh     

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["crontab-ui"]
