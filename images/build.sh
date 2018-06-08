#!/bin/sh -e

for ver in base/*; do
    docker build --no-cache $ver --tag base/julia:$(basename $ver)
done

for ver in derived/*; do
    docker build $ver --tag juliagpu/julia:$(basename $ver)
done
