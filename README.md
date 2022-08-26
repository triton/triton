Triton
======

This repo is the untouched commit history for triton-linux-distribution and
triton-software-distribution.

```sh
git clone triton triton-software-distribution/
git filter-repo \
    --paths nixos/ \
    --paths services \
    --invert-paths
git filter-repo \
    --path-rename pkgs/build-support/:build-support/ \
    --path-rename pkgs/stdenv/:stdenv/ \
    --path-rename pkgs/top-level/:sets/ \
    --path-rename maintainers/scripts:tools/ \
    --path-rename maintainers/docker/Dockerfile:Dockerfile \
    --path-rename maintainers/docker/.dockerignore:.dockerignore

git clone triton triton-linux-distribution/
git filter-repo \
    --paths lib/ \
    --paths pkgs/ \
    --paths tools/ \
    --paths Dockerfile \
    --paths .dockerignore \
    --paths deault.nix \
    --invert-paths
git filter-repo \
    --path-rename nixos/:''
```

