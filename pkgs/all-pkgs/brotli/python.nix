{ stdenv
, buildPythonPackage

, brotli
}:

buildPythonPackage rec {
  name = "brotli-python-${brotli.version}";

  inherit (brotli)
    src
    meta;
}

