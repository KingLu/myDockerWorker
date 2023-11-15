# 使用 u2509/mllab:base 作为基础镜像
FROM u2509/mllab:base

# Docker 构建、推送和运行的示例命令
# docker build -t u2509/mllab:micro -f micro/Dockerfile .
# docker push u2509/mllab:micro
# docker run -d -it -p 8001:8000 --name ml-lab-micro u2509/mllab:micro

# 升级 pip 和 setuptools
RUN pip install -U pip setuptools &&\
    clean-layer.sh

# 更新 apt-get 并安装必要的包
RUN apt-get update --fix-missing && \
    apt-get install -y build-essential python3-dev &&\
    clean-layer.sh

# 使用 conda 安装 jupyterlab_widgets 和 ipywidgets
RUN conda install -n base -c conda-forge jupyterlab_widgets &&\
    conda install -n base -c conda-forge ipywidgets &&\
    clean-layer.sh

# 安装 JupyterLab 相关的扩展
RUN pip install -U jupyterlab-git jupyter_contrib_nbextensions jupyterlab-language-pack-zh-CN &&\
    clean-layer.sh

# 启用 Jupyter notebook 的扩展
RUN jupyter nbextension enable --py widgetsnbextension

# 创建 JupyterLab 的用户设置目录
RUN mkdir -p /root/.jupyter/lab/user-settings/@jupyterlab/translation-extension

# 创建配置文件并设置为中文
RUN echo '{ "locale": "zh-CN" }' > /root/.jupyter/lab/user-settings/@jupyterlab/translation-extension/plugin.jupyterlab-settings

# 暴露端口 8000
EXPOSE 8000

# 设置容器的启动入口
ENTRYPOINT ["jupyterhub_init.sh"]
