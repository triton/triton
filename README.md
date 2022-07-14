Triton
======

This repo is the untouched commit history for triton-linux-distribution and
triton-software-distribution.

```sh
git clone triton triton-software-distribution/
git filter-repo \
    --paths nixos/ \
    --paths services \
    --paths pkgs/development/haskell-modules/ \
    --paths pkgs/development/libraries/haskell/ \
    --invert-paths

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

