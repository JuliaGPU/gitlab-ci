# JuliaGPU GitLab CI

**NOTE: JuliaGPU CI is moving to Buildkite. See
[JuliaGPU/buildkite](https://github.com/JuliaGPU/buildkite) for instructions
on how to use the new system.**

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

* repository -> protected branches: unprotect the `master` branch, or mirroring
  can break in the event of forced pushes (note that it's perfectly fine to keep
  the Github master branch protected)

* CI/CD -> runners settings: make sure available group runners are available and enabled.

* Ci/CD -> secret variables: provide a `CODECOV_TOKEN` (optional)


Now add a `.gitlab-ci.yml` at the root of your repo:

```yaml
include: https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/v6.yml

test:1.0:
  extends:
    - .julia:1.0
    - .test
  tags:
      - nvidia

test:1.x:
  extends:
    - .julia:1
    - .test
  tags:
      - nvidia

test:nightly:
  extends:
    - .julia:nightly
    - .test
  tags:
      - nvidia
  allow_failure: true
```

Each job extends two existing recipes: a `.julia` recipe that downloads Julia,
and a `.test` target that defines the basic testing harness. These jobs will run
on the default image as registered by the CI runner, typically an image by
NVIDIA providing the latest CUDA toolkit supported by the driver on the runner.
There is normally no need to change the `image` (unless, e.g., you want to force
use of artifacts by using a plain `ubuntu` image).

The repository also defines recipes for other common operations:

- `.coverage`: install Coverage.jl and submit coverage information to Codecov
- `.documentation`: build documentation from the `docs/` subproject. This job
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
test:1.0:
  extends:
    - .julia:1.0
    - .test
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



## Runner tags

Several runners are available to the JuliaGPU group, and you can use the
following tags to select specific ones:

* `nvidia`: runners that support NVIDIA CUDA.
* `latest`: select a runner with compute capability >= 7.0, for use of recent
  features like WMMA. More specific tags are available too, e.g. `sm_75`, but
  that does not allow specifying a minimum or maximum capability.
* `cuda_11.0`, etc.: to select a runner that's compatible with a specific CUDA
  version.
* `intel`: runners that support Intel oneAPI. These runners contain Gen9 IGPs.


## Hacking

When doing development to the templates in this repository, do know that the
template files as included by GitLab CI/CD configurations are cached. To
effectively iterate on the template files, be sure to include the commit hash in
the path to the template files.
