# JuliaGPU GitLab CI

This repository contains instructions and resources related to the GitLab CI
infrastructure for the JuliaGPU organization.


## Quick start

Your project needs to be part of the GitLab JuliaGPU group:

* request permission to join the [GitLab JuliaGPU
  group](https://gitlab.com/JuliaGPU)

* import your project (*New Project*, *CI/CD for external repo*), making sure
  you import it to the JuliaGPU group and not your own account


On the page of your new repo:

* general pipeline settings: enable the Simplecov coverage regex

* secret variables: provide a CODECOV_TOKEN

* runners settings: make sure available group runners are available and enabled,
  and shared runners are disabled


Now add a `.gitlab-ci.yml` in the root of your repo, based on the following
template:

```yaml
.test_template: &test_definition
  script:
    - julia -e 'using InteractiveUtils; versioninfo()'
    - julia -e "using Pkg; pkg\"develop $CI_PROJECT_DIR\""
    - julia -e "using Pkg; pkg\"build $CI_PROJECT_NAME\""
    - julia -e "using Pkg; pkg\"test $CI_PROJECT_NAME\""

test:0.6:
  image: juliagpu/julia:v0.6
  <<: *test_definition

test:0.7:
  image: juliagpu/julia:v0.7
  <<: *test_definition

test:dev:
  image: juliagpu/julia:dev
  <<: *test_definition
```


## Group runners

The following runners are shared with the JuliaGPU group:

* `hydor.elis.ugent.be`: Pascal GTX 1080, CUDA 9.1, 64-bit Linux


## Docker images

The following images are available:

* `juliagpu/julia:v0.6`
* `juliagpu/julia:v0.7`
* `juliagpu/julia:dev`

These images need to be build on the system where the GitLab runner is deployed
(see `images/build.sh`), configured with the `pull_policy = "if-not-present"`.
Furthermore, the runner should use the NVIDIA docker runtime, via `runtime =
"nvidia"`.
