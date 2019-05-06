{ stdenv
, fetchurl
}:

{ package
, version
, ...
} @ args:

let
  archive = "tar.gz";
in
fetchurl (rec {
  name = "${package}-${version}.${archive}";
  url = "https://crates.io/api/v1/crates/${package}/${version}/download";
} // removeAttrs args [
  "package"
  "version"
])
