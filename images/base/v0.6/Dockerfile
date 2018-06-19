FROM ubuntu:16.04


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

RUN cp -L /usr/lib/x86_64-linux-gnu/libgfortran.so.3 /opt/julia/usr/lib/
