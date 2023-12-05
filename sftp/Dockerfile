# 基于 Ubuntu 22.04 的 Dockerfile，用于创建支持 SFTP 和 SSH 的容器，同时包含 Webmin 管理界面
# 使用方法：
# 1. 构建镜像：在包含此 Dockerfile 的目录中运行 `docker build -t sftp-worker: .`
# 2. 运行容器：使用 `docker run -p 10022:22 -p 10000:10000 -d sftp-worker`
#    其中，`your-image-name` 是您给镜像指定的名字
# 3. 访问 SFTP/SSH：使用端口 22
# 4. 访问 Webmin 管理界面：浏览器访问 `http://[容器IP]:10000`

# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

COPY scripts/clean_layer.sh /usr/bin/clean-layer.sh
RUN  chmod 755 /usr/bin/clean-layer.sh

RUN \
    apt-get update &&\
    apt-get install -y locales &&\
    sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen &&\
    locale-gen &&\
    clean-layer.sh

# 安装必要的软件包
RUN \
    apt-get update &&\
    apt-get install -y openssh-server sudo wget vim curl wget &&\
    clean-layer.sh

# 安装 Webmin依赖
RUN \
    apt-get update &&\
    apt-get install -y net-tools iproute2 perl-modules &&\
    clean-layer.sh

# 安装 Webmin 和其他依赖
RUN \
    curl -o setup-repos.sh https://raw.githubusercontent.com/webmin/webmin/master/setup-repos.sh &&\
    echo 'y' | sh setup-repos.sh &&\
    apt-get update &&\
    apt-get install -y webmin --install-recommends &&\
    apt-get autoremove -y &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*

# 配置 SSH 和 SFTP
RUN mkdir /var/run/sshd
RUN echo "root:${ROOTPWD:-root@Adm}" | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH 登录修复。否则用户将无法登录。
RUN sed -ri 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config


# 开放 SSH 和 Webmin 端口
EXPOSE 22 10000

# 配置 Webmin
RUN echo "bind=0.0.0.0" >> /etc/webmin/miniserv.conf

# 将初始化脚本复制到容器
COPY scripts/docker_init.sh /usr/local/bin/docker_init.sh
RUN chmod +x /usr/local/bin/docker_init.sh

# 使用初始化脚本启动服务
CMD ["/usr/local/bin/docker_init.sh"]
