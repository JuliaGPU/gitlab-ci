# JuliaGPU GitLab CI

This repository contains instructions and resources related to the GitLab CI
infrastructure for the JuliaGPU organization. It can be used to add GPU CI
to Julia packages, as long as there's a publicly-accessible git repository.


## Usage

First of all, you need to be the owner of your repository or Gitlab will fail
to add a webhook.

Your project also needs to be part of the GitLab JuliaGPU group:

* request permission to join the [GitLab JuliaGPU
  group](https://gitlab.com/JuliaGPU)

* import your project (*New Project*, *CI/CD for external repo*), making sure
  you import it to the JuliaGPU group and not your own account


On the settings page of your new repo:

* general: change the project visibility to `Public`

* repository -> protected branches: unprotect the `master` branch, or mirroring
  can break in the event of forced pushes (note that it's perfectly fine to keep
  the Github master branch protected)

* CI/CD -> runners settings: make sure available group runners are available and
  enabled, and shared runners are disabled

* Ci/CD -> secret variables: provide a `CODECOV_TOKEN` (optional)


Now add a `.gitlab-ci.yml` at the root of your repo:

```yaml
variables:
  CI_IMAGE_TAG: 'cuda'

include:
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/v5/test.yml'

test:v1.0:
  extends: .test:v1.0

test:dev:
  extends: .test:dev
  allow_failure: true
```

The `CI_IMAGE_TAG` variable determines which Docker image will be used (see
below). You should always include the `test.yml` file and define some `test`
targets that extend from the `.test` recipes. Multiple of these recipes are
provided: one for each supported version of Julia, a `:dev` version for the
latest nightly, and `:source` if you need Julia built from source.

This repository also provides some files to include that define concrete jobs:

- `coverage.yml`: install Coverage.jl and submit coverage information to Codecov
- `documentation.yml`: build documentation from the `docs/` subproject. This job
  does not submit, as Documenter.jl does not support Gitlab. Instead, you can
  use a deploy phase with Gitlab pages to host the documentation:
  ```
  pages:
  stage: deploy
  script:
    - mv docs/build public
  artifacts:
    paths:
    - public
  only:
    - master
  ```


### Pull requests from forks

If you only ever want to build changes from branches on your repo, no further
set-up is required. However, if you want CI for e.g. pull-requests from forks,
you need to work around a [GitLab
limitation](https://gitlab.com/gitlab-org/gitlab-ee/issues/5667). One
possibility is to mirror those external changes onto your repository. This can
be automated with Bors, a merge bot for GitHub pull requests. Follow the
instructions on their [home page](https://bors.tech/), and if you want to use
Bors exclusively update your `gitlab-ci.yml` to only build the `trying` and
`staging` branches for any job you've enabled (global filters [are not supported
yet](https://gitlab.com/gitlab-org/gitlab-ce/issues/49167)). For example:

```yaml
test:v1.0:
  only:
    - staging
    - trying

test:dev:
  allow_failure: true
  only:
    - staging
    - trying

documentation:
  only:
    - staging
    - trying

coverage:
  only:
    - staging
    - trying
```

Finally, use the following `bors.toml` configuration file to require successful
builds on the `staging` branch:

```toml
status = [
  "ci/gitlab/%"
]
```



## Group runners

The following runners are shared with the JuliaGPU group:

* `hydor.elis.ugent.be`: Kepler GTX Titan & Pascal GTX 1080, CUDA 9.0, 64-bit Linux

Note that you need to disable shared runners on your repository in Gitlab
(in `Settings/CI / CD`) - otherwise, you may run on a Gitlab shared runner,
instead off a JuliaGPU one.  Gitlab shared runners usually do not have GPUs.

## Docker images

Images are named according to `juliagpu/julia:$VERSION-$TAG`, and use the
precompiled binaries from the Julia home page. When using the templates from
this repository, you also need to select one of the following tags using the
`CI_IMAGE_TAG` variable:

* `plain`: `ubuntu` image
* `cuda`: `nvidia/cuda` image with CUDNN
* `opencl`: `nvidia/opencl` image
* `opengl`: `nvidia/opengl` image

All images come with essential compiler utilities, but few other packages. If
you are missing a package, either install it as part of the build process, or
file an issue here.

If you want to use these images, make sure the runner uses the NVIDIA docker
runtime, via `runtime = "nvidia"`. For the OpenGL images, there should be an X
server running on display `:0` (hard-coded in the Dockerfile, as the
`environment` flag in the runner config doesn't seem to work), and the runner
should mount `/tmp/.X11-unix` in the container (i.e., `volumes =
[/tmp/.X11-unix:/tmp/.X11-unix:ro"]`).



# Hacking

When doing development to the templates in this repository, do know that the
template files as included by GitLab CI/CD configurations are cached. To prevent
this, and make sure your changes are picked up, be sure to 1) clear the runner
cache on the pipeline overview page of the repository that includes the
templates, and 2) the top commit on the target repository changes (an empty
`commit --amend` suffices),
