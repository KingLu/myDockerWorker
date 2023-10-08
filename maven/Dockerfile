# docker build -t maven:3.6.3-jdk-11-alpine-20230804 .
# 使用alpine为基础镜像
FROM alpine

# 替换为中国的镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# 安装 Maven 3.6
ENV MAVEN_VERSION=3.6.3
ENV MAVEN_HOME=/opt/maven

RUN apk add --no-cache curl && \
    curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar -xz -C /opt/ && \
    ln -s /opt/apache-maven-$MAVEN_VERSION /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm -rf /var/cache/apk/*

# 安装 OpenJDK 11
RUN apk add --no-cache openjdk11 && \
    rm -rf /var/cache/apk/*

# 安装 zip, curl, wget, git, jq, openssh-client, sshpass
RUN apk add --no-cache zip unzip wget git jq openssh-client sshpass && \
    rm -rf /var/cache/apk/*

# 设置 Maven 和 OpenJDK 环境变量
ENV JAVA_HOME=/usr/lib/jvm/default-jvm
ENV PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# 指定工作目录（可根据需要修改）
WORKDIR /app

# 可以在这里添加您的其他命令或配置，如复制文件等

# 指定容器启动时要运行的命令
CMD ["bash"]
