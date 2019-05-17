FROM ubuntu:18.04


## installation

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
                    # basic stuff
                    curl ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/julia/usr && \
    curl -s -L https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.4-linux-x86_64.tar.gz | tar -C /opt/julia/usr -x -z --strip-components=1 -f -


## execution

WORKDIR /

RUN ln -s /opt/julia/usr/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/usr/bin/julia-debug /usr/bin/julia-debug
