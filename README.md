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

* general settings: change the project visibility to `Public`

* runners settings: make sure available group runners are available and enabled,
  and shared runners are disabled

* secret variables: provide a `CODECOV_TOKEN` (optional)


Now add a `.gitlab-ci.yml` in the root of your repo, based on the following
template:

```yaml
.test_template: &test_definition
  script:
    - julia -e 'using InteractiveUtils; versioninfo()'
    # actual testing
    # TODO: `Pkg.build(); Pkg.test(; coverage=true)` once that works
    - julia -e "using Pkg;
                Pkg.develop(\"$CI_PROJECT_DIR\");
                Pkg.build(\"$package\");
                Pkg.test(\"$package\"; coverage=true)"
    # coverage (needs CODECOV_TOKEN secret variable)
    - julia -e 'using Pkg; Pkg.add("Coverage")'
    - julia -e 'using Coverage;
                cl, tl = get_summary(process_folder());
                println("(", cl/tl*100, "%) covered");
                Codecov.submit_local(process_folder(), ".")'
  coverage: '/\(\d+.\d+\%\) covered/'

variables:
  package: 'PackageName'

test:0.7:
  image: juliagpu/julia:v0.7
  <<: *test_definition

test:dev:
  image: juliagpu/julia:dev
  <<: *test_definition
```

For testing 0.6, you'd need to use the old package manager:

```yaml
.test_template: &test_definition
  script:
    - julia -e 'versioninfo()'
    # actual testing
    - julia -e "Pkg.init();
                symlink(\"$CI_PROJECT_DIR\", joinpath(Pkg.dir(), \"$package\"));
                Pkg.resolve();
                Pkg.build(\"$package\");
                Pkg.test(\"$package\"; coverage=true)"
    # coverage (needs CODECOV_TOKEN secret variable)
    - julia -e 'using Pkg; Pkg.add("Coverage")'
    - julia -e 'using Coverage;
                cl, tl = get_summary(process_folder());
                println("(", cl/tl*100, "%) covered");
                Codecov.submit_local(process_folder(), ".")'
  coverage: '/\(\d+.\d+\%\) covered/'

test:0.6:
  image: juliagpu/julia:v0.6
  <<: *test_definition
```

If you want more control over individual steps, you can divide the process in
stages and pass files between them. This has the advantage that you can download
each job's artifacts for local inspection.

```yaml
before_script:
  - julia -e 'using InteractiveUtils; versioninfo()'

variables:
  JULIA_DEPOT_PATH: "$CI_PROJECT_DIR/.julia/"
  package: 'PackageName'

stages:
  - test
  - postprocess


## testing

.test_template: &pkg3_test_template
  script:
    - mkdir $JULIA_DEPOT_PATH # Pkg3.jl#325
    - julia -e "using Pkg;
                Pkg.develop(\"$CI_PROJECT_DIR\");
                Pkg.build(\"$package\");
                Pkg.test(\"$package\"; coverage=true)"
  artifacts:
    paths:
      - .julia/
      - deps/ext.jl
      - src/*.cov
      - src/*/*.cov # gitlab-runner#2620

test:dev:
  stage: test
  image: juliagpu/julia:dev
  <<: *pkg3_test_template


## post-processing

coverage: # needs CODECOV_TOKEN secret variable if you want to deploy
  stage: postprocess
  image: juliagpu/julia:dev
  dependencies:
    - test:dev
  script:
    - julia -e 'using Pkg; Pkg.add("Coverage")'
    - julia -e 'using Coverage;
                cl, tl = get_summary(process_folder());
                println("(", cl/tl*100, "%) covered");
                Codecov.submit_local(process_folder(), ".")'
  coverage: '/\(\d+.\d+\%\) covered/'

documentation: # needs DOCUMENTER_KEY secret variable if you want to deploy
  stage: postprocess
  image: juliagpu/julia:dev
  dependencies:
    - test:dev
  script:
    - julia -e 'using Pkg; Pkg.add("Documenter")'
    - julia docs/make.jl
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
