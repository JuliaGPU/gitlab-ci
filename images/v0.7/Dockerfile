FROM nvidia/cuda:9.1-cudnn7-devel-ubuntu16.04

MAINTAINER Tim Besard <tim.besard@gmail.com>

RUN apt-get update && \
    apt-get install --yes --no-install-recommends curl && \
    apt-get clean && \
rm -rf /var/lib/apt/lists/*

RUN curl -s -L https://julialang-s3.julialang.org/bin/linux/x64/0.7/julia-0.7.0-alpha-linux-x86_64.tar.gz | tar -C /usr -x -z --strip-components=1 -f -
