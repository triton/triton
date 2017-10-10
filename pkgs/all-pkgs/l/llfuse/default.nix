{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attr
, fuse_2
}:

let
  version = "1.3";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "d1ab2c7cdaeed1c4c99882f2ad44df3906db263b832d76de18291e484c685bd2";
  };

  buildInputs = [
    attr
    fuse_2
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
