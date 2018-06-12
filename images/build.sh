#!/bin/bash -e

# either rebuild all base images, or let the user specify
if [[ "$#" -eq 0 ]]; then
    IMAGES=$(ls base/*)
    IMAGES=()
    for base in base/*; do
        IMAGES+=($(basename $base))
    done
else
    IMAGES=("$@")
fi

for base in ${IMAGES[@]}; do
    docker build --quiet --no-cache base/$base --tag base/julia:$base

    for derived in derived/${base}*; do
        docker build --quiet $derived --tag juliagpu/julia:$(basename $derived)
    done
done

