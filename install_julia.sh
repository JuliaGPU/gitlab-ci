#!/usr/bin/env sh

apt-get -qq update
apt-get -qqy install curl > /dev/null

case "$CI_RUNNER_EXECUTABLE_ARCH" in
  "linux/amd64")
    larch="x64"
    rarch="x86_64"
    nightly_rarch="64"
    ;;
  "linux/arm64")
    larch="aarch64"
    rarch="aarch64"
    nightly_rarch="aarch64"
    ;;
  *)
    echo "Unsupported platform: $CI_RUNNER_EXECUTABLE_ARCH" >&2
    echo "exit 1"
    exit
    ;;
esac

version="$1"
if [[ "$version" == "nightly" ]]; then
  url="https://julialangnightlies-s3.julialang.org/bin/linux/$larch/julia-latest-linux$nightly_rarch.tar.gz"
else
  url="https://julialang-s3.julialang.org/bin/linux/$larch/$version/julia-$version-latest-linux-$rarch.tar.gz"
fi

curl -sSL "$url" | tar -C /usr/local --strip-components=1 -zxf -

julia -e 'using InteractiveUtils; versioninfo()' >&2
JULIA_LLVM_ARGS='--version' julia >&2

# https://gitlab.com/gitlab-org/gitlab-runner/issues/327
# https://gitlab.com/gitlab-org/gitlab/issues/16343
echo 'export JULIA_DEPOT_PATH="$CI_PROJECT_DIR/.julia"'
echo 'export JULIA_PROJECT="@."'
