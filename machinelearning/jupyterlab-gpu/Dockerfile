# 使用nvidia/cuda:12.2.2-devel-ubuntu22.04为基础镜像
# docker build -t jupyterlab:cuda12-ubuntu22.04 .

# 基于 NVIDIA CUDA 12.2.2 和 Ubuntu 22.04 的开发环境镜像
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

#################################################################################################################
#           全局设置
#################################################################################################################
# 通过设置环境变量 DEBIAN_FRONTEND=noninteractive 和 apt-get install -y 来跳过任何交互式的后安装配置步骤

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

#################################################################################################################
#           全局路径设置
#################################################################################################################

ENV CUDA_HOME /usr/local/cuda
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/lib

ENV OPENCL_LIBRARIES /usr/local/cuda/lib64
ENV OPENCL_INCLUDE_DIR /usr/local/cuda/include

#################################################################################################################
#           TINI
#################################################################################################################

# 安装 tini
COPY tini /tini
RUN chmod +x /tini

#################################################################################################################
#           系统设置
#################################################################################################################
# 使用 apt-get update 来下载来自仓库的包列表并更新它们，以获取包及其依赖项的最新版本信息。

RUN apt-get update && \
apt-get install -y --no-install-recommends \
build-essential \
curl \
bzip2 \
ca-certificates \
libglib2.0-0 \
libxext6 \
libsm6 \
libxrender1 \
git \
vim \
mercurial \
subversion \
cmake \
libboost-dev \
libboost-system-dev \
libboost-filesystem-dev \
gcc \
g++

# 为 LightGBM 添加 OpenCL ICD 文件
RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

#################################################################################################################
#           CONDA
#################################################################################################################

ARG CONDA_DIR=/opt/miniforge
# 添加到路径
ENV PATH $CONDA_DIR/bin:$PATH

# 安装 miniforge
COPY Miniforge3-Linux-x86_64.sh /root/Miniforge3-Linux-x86_64.sh
RUN /bin/bash /root/Miniforge3-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm /root/Miniforge3-Linux-x86_64.sh


RUN conda config --set always_yes yes --set changeps1 no && \
    conda create -y -q -n py3 numpy scipy scikit-learn jupyter notebook ipython pandas matplotlib

#################################################################################################################
#           LightGBM
#################################################################################################################

RUN cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
    git clone --recursive --branch stable --depth 1 https://github.com/microsoft/LightGBM && \
    cd LightGBM && mkdir build && cd build && \
    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
    make OPENCL_HEADERS=/usr/local/cuda-8.0/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda-8.0/targets/x86_64-linux/lib

ENV PATH /usr/local/src/lightgbm/LightGBM:${PATH}

RUN /bin/bash -c "source activate py3 && cd /usr/local/src/lightgbm/LightGBM && sh ./build-python.sh install --precompile && source deactivate"

#################################################################################################################
#           系统清理
#################################################################################################################
# 使用 apt-get autoremove 来移除为满足某些包的依赖而自动安装的包，现在不再需要它们了。
# 使用 apt-get clean 来移除 /var/cache/apt/archives 中的 aptitude 缓存。你会惊讶于那里有多少内容！唯一的缺点是，如果你重新安装它们，包必须再次下载。

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -a -y

#################################################################################################################
#           JUPYTER
#################################################################################################################

# 密码: keras
# 密码键: --NotebookApp.password='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# 添加 notebook 配置文件
RUN mkdir -p -m 700 ~/.jupyter/ && \
    echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py

VOLUME /home
WORKDIR /home

# IPython
EXPOSE 8888

ENTRYPOINT [ "/tini", "--" ]
CMD /bin/bash -c "source activate py3 && jupyter notebook --allow-root --no-browser --NotebookApp.password='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824' && source deactivate"
