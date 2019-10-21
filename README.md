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
include:
  - 'https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/v6.yml'

test:1.0:
  extends:
    - .julia:1.0
    - .test

test:nightly:
  extends:
    - .julia:nightly
    - .test
  allow_failure: true
```

Each job extends two existing recipes: a `.julia` recipe that downloads Julia, and a `.test`
target that defines the basic testing harness. These jobs will run on the default image as
registered by the CI runner, typically an image without GPU support. To actually run make
use of the GPU, specify an appropriate image and request a runner with a GPU as follows:

```yaml
test:1.0:
  extends:
    - .julia:1.0
    - .test
  tags:
    - nvidia
  image: nvidia/cuda:latest
```

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



## Group runners

The following runners are shared with the JuliaGPU group:

* `hydor.elis.ugent.be`: Pascal GTX 1080 & Turing RTX 20180 Ti, 64-bit Linux
* `ripper.elis.ugent.be`: Kepler GTX Titan, 64-bit Linux

Note that you need to disable shared runners on your repository in Gitlab
(in `Settings/CI / CD`) - otherwise, you may run on a Gitlab shared runner,
instead off a JuliaGPU one.  Gitlab shared runners usually do not have GPUs.



## Hacking

When doing development to the templates in this repository, do know that the
template files as included by GitLab CI/CD configurations are cached. To
effectively iterate on the template files, be sure to include the commit hash in
the path to the template files.
