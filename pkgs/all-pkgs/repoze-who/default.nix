{ stdenv
, buildPythonPackage
, fetchPyPi

, webob
, zope-interface
}:

let
  version = "2.3";
in
buildPythonPackage {
  name = "repoze.who-${version}";

  src = fetchPyPi {
    package = "repoze.who";
    inherit version;
    sha256 = "b95dadc1242acc55950115a629cfb1352669774b46d22def51400ca683efea28";
  };

  propagatedBuildInputs = [
    webob
  ];

  buildInputs = [
    zope-interface
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
