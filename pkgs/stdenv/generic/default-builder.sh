for defaultBuilderSrc in "$stdenv"/share/stdenv/*; do
  source "$defaultBuilderSrc"
done
genericBuild
