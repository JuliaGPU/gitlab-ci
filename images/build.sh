#!/bin/bash -ue

# either rebuild all base images, or let the user specify
if [[ "$#" -eq 0 ]]; then
    IMAGES=$(ls base/*)
    IMAGES=()
    for base_tree in base/*; do
        IMAGES+=($(basename $base_tree))
    done
else
    IMAGES=("$@")
fi

for base in ${IMAGES[@]}; do
    base_tree=base/$base
    base_tag=juliagpu/julia:$base

    docker build --quiet --no-cache $base_tree --tag $base_tag

    for derived_tree in derived/*; do
        derived=$(basename $derived_tree)
        derived_tag=juliagpu/julia:$base-$derived

        docker build --quiet --build-arg base=$base $derived_tree --tag $derived_tag
    done
done
