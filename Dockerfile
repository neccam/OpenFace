FROM ubuntu:16.04

LABEL maintainer="Necati Cihan Camgoz <n.camgoz@surrey.ac.uk>"

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_DIR=/home/build-dep

ARG OPENFACE_DIR=/home/openface-build

RUN mkdir ${OPENFACE_DIR}
WORKDIR ${OPENFACE_DIR}

COPY ./CMakeLists.txt ${OPENFACE_DIR}

COPY ./cmake ${OPENFACE_DIR}/cmake

COPY ./exe ${OPENFACE_DIR}/exe

COPY ./lib ${OPENFACE_DIR}/lib

# Essential Dependencies
RUN apt-get update && apt-get install -y -qq \
    apt-utils \
    build-essential \
    cmake \
    libopenblas-dev liblapack-dev \
    git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
    python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev \
    libboost-all-dev wget unzip curl llvm clang-3.7 libc++-dev libc++abi-dev  libjasper-dev  checkinstall && \
    rm -rf /var/lib/apt/lists/*

# Download Models
RUN cd ${OPENFACE_DIR}/lib/local/LandmarkDetector/model/patch_experts/ && \
    wget https://www.dropbox.com/s/7na5qsjzz8yfoer/cen_patches_0.25_of.dat && \
    wget https://www.dropbox.com/s/k7bj804cyiu474t/cen_patches_0.35_of.dat && \
    wget https://www.dropbox.com/s/ixt4vkbmxgab1iu/cen_patches_0.50_of.dat && \
    wget https://www.dropbox.com/s/2t5t1sdpshzfhpj/cen_patches_1.00_of.dat

RUN mkdir ${BUILD_DIR}

# OpenCV Dependency
RUN cd ${BUILD_DIR} && \
    wget https://github.com/opencv/opencv/archive/3.4.0.zip && \
    unzip 3.4.0.zip && \
    cd opencv-3.4.0 && \
    mkdir -p build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON -D WITH_CUDA=OFF \
    -D BUILD_SHARED_LIBS=OFF .. && \
    make -j all && \
    make install && \
    cd ../.. && \
    rm 3.4.0.zip && \
    rm -r opencv-3.4.0

# dlib Dependency
RUN cd ${BUILD_DIR} && \
    wget http://dlib.net/files/dlib-19.13.tar.bz2 && \
    tar xf dlib-19.13.tar.bz2 && \
    cd dlib-19.13 && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    make -j all && \
    make install && \
    ldconfig && \
    cd ../.. && \
    rm -r dlib-19.13.tar.bz2

# OpenFace installation
RUN cd ${OPENFACE_DIR} && \
    mkdir -p build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE .. && \
    make -j all

RUN ln /dev/null /dev/raw1394
