ARG base

FROM juliagpu/julia:${base} as base


FROM nvidia/opengl:1.0-glvnd-devel-ubuntu16.04

COPY --from=base /opt/julia /opt/julia

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
                    # essential tools
                    ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug

ENV DISPLAY=:0
