ARG base

FROM juliagpu/julia:${base} as base


# https://hub.docker.com/r/nvidia/opencl/
FROM nvidia/opencl:devel-ubuntu18.04

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
