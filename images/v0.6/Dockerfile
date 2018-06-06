FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

MAINTAINER Tim Besard <tim.besard@gmail.com>


## checkout

WORKDIR /opt

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
                    # basic stuff
                    build-essential ca-certificates \
                    # Julia
                    cmake curl gfortran git m4 python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/JuliaLang/julia.git && \
    cd julia && \
git checkout v0.6.3


## build

WORKDIR /opt/julia

RUN make all -j$(nproc) \
        MARCH=x86-64 \
        JULIA_CPU_TARGET=x86-64 && \
rm -rf deps/scratch deps/srccache usr-staging


## execution

RUN ln -s /opt/julia/usr/bin/julia /usr/bin/julia
