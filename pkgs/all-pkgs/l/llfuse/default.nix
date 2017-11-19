{ stdenv
, buildPythonPackage
, fetchPyPi
, lib

, attr
, fuse_2
}:

let
  version = "1.3.2";
in
buildPythonPackage {
  name = "llfuse-${version}";

  src = fetchPyPi {
    package = "llfuse";
    inherit version;
    type = ".tar.bz2";
    sha256 = "96252a286a2be25810904d969b330ef2a57c2b9c18c5b503bbfbae40feb2bb63";
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
