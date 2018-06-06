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

RUN git clone https://github.com/JuliaLang/julia.git


## build

WORKDIR /opt/julia

RUN make all -j$(nproc) \
        MARCH=x86-64 \
        JULIA_CPU_TARGET=x86-64 && \
rm -rf deps/scratch deps/srccache usr-staging


## execution

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug

