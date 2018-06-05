FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

MAINTAINER Tim Besard <tim.besard@gmail.com>

RUN apt-get update && \
    apt-get install --yes --no-install-recommends curl && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/julia-0.6 && \
    curl -L https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.3-linux-x86_64.tar.gz | tar -C /opt/julia-0.6 -x -z --strip-components=1 -f - && \
    ln -s /opt/julia-0.6/bin/julia /usr/bin/julia-0.6


RUN mkdir /opt/julia-0.7 && \
    curl -L https://julialang-s3.julialang.org/bin/linux/x64/0.7/julia-0.7.0-alpha-linux-x86_64.tar.gz | tar -C /opt/julia-0.7 -x -z --strip-components=1 -f - && \
    ln -s /opt/julia-0.7/bin/julia /usr/bin/julia-0.7


RUN mkdir /opt/julia-dev && \
    curl -L https://julialangnightlies-s3.julialang.org/bin/linux/x64/julia-latest-linux64.tar.gz | tar -C /opt/julia-dev -x -z --strip-components=1 -f - && \
    ln -s /opt/julia-dev/bin/julia /usr/bin/julia-dev
