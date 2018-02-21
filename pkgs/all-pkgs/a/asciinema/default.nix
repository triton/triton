{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.0.0";
in
buildPythonPackage {
  name = "asciinema-${version}";

  src = fetchPyPi {
    package = "asciinema";
    inherit version;
    sha256 = "be193e2513cd309dd8de5b92d22bd48752076fe269ee3fb56da1052e5acc3768";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
