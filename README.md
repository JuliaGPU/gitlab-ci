JuliaGPU Docker containers for CI
=================================

The Docker recipes in this repository are used by JuliaGPU CI runners, e.g., as
used by GitLab CI/CD. The following images are built by the `build.sh` script:

* `juliagpu/julia:v0.6`
* `juliagpu/julia:v0.7`
* `juliagpu/julia:dev`

You should provide these images locally, to be used by e.g. a GitLab runner with
the `pull_policy = "if-not-present"` configuration set.

After pointing GitLab CI/CD to your runner, you can then use the following
sample `.gitlab-ci.yml` file to build using these images:

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
