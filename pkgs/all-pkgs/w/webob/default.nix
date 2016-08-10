{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "1.6.1";
in
buildPythonPackage {
  name = "webob-${version}";

  src = fetchPyPi {
    package = "WebOb";
    inherit version;
    sha256 = "e804c583bd0fb947bd7c03d296942b38b985cf1da4fd82bf879994d29edb21fe";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
