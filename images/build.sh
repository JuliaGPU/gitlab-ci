#!/bin/sh -e

for julia in */; do
    docker build $julia --tag juliagpu/julia:$(basename $julia)
done
