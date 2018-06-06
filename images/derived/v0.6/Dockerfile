FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

RUN apt-get update && \
    apt-get install --yes --no-install-recommends libgfortran3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=base/julia:v0.6 /opt/julia /opt/julia

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug
