{ stdenv
, buildPythonPackage
, fetchPyPi

, six
}:

let
  version = "2.0.3";
in
buildPythonPackage {
  name = "Paste-${version}";

  src = fetchPyPi {
    package = "Paste";
    inherit version;
    sha256 = "2346a347824c32641bf020c17967b49ae74d3310ec1bc9b958d4b84e2d985218";
  };

  buildInputs = [
    six
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
