FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

COPY --from=base/julia:v0.7 /opt/julia /opt/julia

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug
