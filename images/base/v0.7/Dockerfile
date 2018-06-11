FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install --yes --no-install-recommends curl ca-certificates && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/julia && \
    curl -s -L https://julialang-s3.julialang.org/bin/linux/x64/0.7/julia-0.7.0-alpha-linux-x86_64.tar.gz | tar -C /opt/julia -x -z --strip-components=1 -f -

RUN ln -s /opt/julia/bin/julia       /usr/bin/julia && \
    ln -s /opt/julia/bin/julia-debug /usr/bin/julia-debug
