ARG base

FROM juliagpu/julia:${base} as base


# https://hub.docker.com/r/nvidia/opengl/
FROM nvidia/opengl:1.0-glvnd-devel-ubuntu18.04

COPY --from=base /opt/julia /opt/julia

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
                    # tools
                    ca-certificates curl git \
                    # common package dependencies
                    build-essential gfortran && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug

ENV DISPLAY=:0
