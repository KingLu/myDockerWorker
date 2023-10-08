# docker run -d -p 8000:8000 u2509/webcron-ui:base
#docker build -t u2509/webcron-ui:mysql .

FROM u2509/webcron-ui:base


## 安装mysql-client
RUN apt-get update --fix-missing && apt-get install -y default-mysql-client &&\   
    clean-layer.sh

ENV   HOST 0.0.0.0

ENV   PORT 8000

ENV   CRON_IN_DOCKER true

EXPOSE $PORT

CMD ["supervisord", "-c", "/etc/supervisord.conf"]