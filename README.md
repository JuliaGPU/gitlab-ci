# JuliaGPU GitLab CI

This repository contains instructions and resources related to the GitLab CI
infrastructure for the JuliaGPU organization. It can be used to add GPU CI
to Julia packages, as long as there's a publicly-accessible git repository.


## Quick start

You need to be the owner if your repository, or Gitlab will fail to add a
webhook.

Your project also needs to be part of the GitLab JuliaGPU group:

* request permission to join the [GitLab JuliaGPU
  group](https://gitlab.com/JuliaGPU)

* import your project (*New Project*, *CI/CD for external repo*), making sure
  you import it to the JuliaGPU group and not your own account


On the settings page of your new repo:

* general: change the project visibility to `Public`

* repository -> protected branches: unprotect the `master` branch, or mirroring
  can break in the event of forced pushes

* CI/CD -> runners settings: make sure available group runners are available and
  enabled, and shared runners are disabled

* Ci/CD -> secret variables: provide a `CODECOV_TOKEN` (optional)


Now add a `.gitlab-ci.yml` in the root of your repo, based on the templates in
this repository:

```yaml
variables:
  CI_IMAGE_TAG: '-cuda'

stages:
  - test
  - postprocess

include:
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/common.yml'
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/test_v0.7.yml'
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/test_v1.0.yml'
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/test_dev.yml'
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/postprocess_coverage.yml'
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/postprocess_documentation.yml'

test:dev:
  allow_failure: true
```

These templates are pretty coarse, and might not be compatible with your
package. In that case, just copy the contents in your `.gitlab.yml` and
customize the build where necessary.


## Group runners

The following runners are shared with the JuliaGPU group:

* `hydor.elis.ugent.be`: Pascal GTX 1080, CUDA 9.1, 64-bit Linux


## Docker images

The following images are available:

* `juliagpu/julia:v0.6-cuda`
* `juliagpu/julia:v0.7-cuda`
* `juliagpu/julia:v1.0-cuda`
* `juliagpu/julia:dev-cuda`
* `juliagpu/julia:v0.6-opencl`
* `juliagpu/julia:v0.7-opencl`
* `juliagpu/julia:v1.0-opencl`
* `juliagpu/julia:dev-opencl`
* `juliagpu/julia:v0.6-opengl`
* `juliagpu/julia:v0.7-opengl`
* `juliagpu/julia:v1.0-opengl`
* `juliagpu/julia:dev-opengl`

When using the templates from this repository, you only need to specify the
trailing tag (eg. `-cuda`) using the CI_IMAGE_TAG variable.

Note that we don't push these images to a Docker registry, but build them on the
the system where the GitLab runner is deployed (see `images/build.sh`),
configured with the `pull_policy = "if-not-present"`. IF you want to use these
images, make sure the runner uses the NVIDIA docker runtime, via `runtime =
"nvidia"`. For the OpenGL images, there should be an X server running on display
`:0` (hard-coded in the Dockerfile, as the `environment` flag in the runner
config doesn't seem to work), and the runner should mount `/tmp/.X11-unix` in
the container (i.e., `volumes = [/tmp/.X11-unix:/tmp/.X11-unix:ro"]`).
