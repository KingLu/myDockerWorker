# 使用指定版本的Node.js作为基础镜像
# docker build -t node:12.22.12-alpine3.15-diy .
FROM node:12.22.12-alpine3.15

# 设置为root用户
USER root

# 设置淘宝的npm镜像
RUN npm config set registry https://registry.npm.taobao.org

# 安装node-sass
RUN npm install -g node-sass@4.14.1 --sass-binary-site=http://npm.taobao.org/mirrors/node-sass  --unsafe-perm=true --allow-root

# insall zip
RUN apk add zip unzip

# insall zip
RUN apk add curl wget

# insall zip
RUN apk add --update git
RUN apk add --update jq
RUN apk add --update openssh-client
RUN apk add --update sshpass
