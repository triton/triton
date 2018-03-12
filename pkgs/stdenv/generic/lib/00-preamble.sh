set -e
set -o pipefail

# All builds should guarantee pure build outputs
export NIX_ENFORCE_PURITY=1
