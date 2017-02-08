{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "0.2.2";
in
buildPythonPackage {
  name = "pyasn1-${version}";

  src = fetchPyPi {
    package = "pyasn1";
    inherit version;
    sha256 = "6b42f96b942406712e0be5ea2bbbc57d8f30c7835a4904c9c195cc669736d435";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
