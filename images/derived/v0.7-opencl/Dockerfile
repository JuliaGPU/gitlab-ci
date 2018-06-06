FROM nvidia/opencl:devel-ubuntu16.04

COPY --from=base/julia:v0.7 /opt/julia /opt/julia

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
                    # essential tools
                    curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug
