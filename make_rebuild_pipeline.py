import os

from random import choice
from sys import stdout
from uuid import uuid4

import yaml


def env_list(k):
    return [s.strip() for s in os.getenv(k, "").split(",") if s]


folder = os.getenv("FOLDER")
file = os.getenv("FILE")
if not folder or not file:
    cwd = os.getcwd()
    os.chdir(os.environ["CONTENT_DIR"])
    exclude = env_list("EXCLUDE")
    dirs = [d for d in os.listdir() if os.path.isdir(d)]
    choices = [
        (d, f) for d in dirs for f in os.listdir(d)
        if f.endswith(".jmd") and f"{d}/{f}" not in exclude
    ]
    folder, file = choice(choices)
    os.chdir(cwd)

tags = env_list("TAGS")
if f"{folder}/{file}" in env_list("NEEDS_GPU"):
    tags.append("nvidia")

package = os.environ["GITHUB_REPOSITORY"].split("/")[1]
if package.endswith(".jl"):
    package = package[:-3]

script = f"""
julia -e '
  using Pkg
  Pkg.instantiate()
  using {package}: weave_file
  weave_file("{folder}", "{file}")'

if [[ -z "$(git status -suno)" ]]; then
  echo "No changes"
  exit 0
fi

k="$(cat $SSH_KEY)"
echo "$k" > "$SSH_KEY"
chmod 400 "$SSH_KEY"
git config core.sshCommand "ssh -o StrictHostKeyChecking=no -i $SSH_KEY"
git config user.name "github-actions[bot]"
git config user.email "actions@github.com"
branch="rebuild/{str(uuid4())[:8]}"
git checkout -b "$branch"
git commit -am "Rebuild content"
git remote add github "git@github.com:$GITHUB_REPOSITORY.git"
git push github "$branch"
"""

pipeline = {
    "include": "https://raw.githubusercontent.com/JuliaGPU/gitlab-ci/master/templates/v6.yml",
    "rebuild": {
        "extends": ".julia:1.4",
        "variables": {
            "CI_APT_INSTALL": "git python3-dev texlive-science texlive-xetex",
            "JULIA_NUM_THREADS": 4,
        },
        "tags": tags,
        "script": script,
    },
}

yaml.dump(pipeline, stdout)
