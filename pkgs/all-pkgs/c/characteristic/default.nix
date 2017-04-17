{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "14.3.0";
in
buildPythonPackage {
  name = "characteristic-${version}";

  src = fetchPyPi {
    package = "characteristic";
    inherit version;
    sha256 = "ded68d4e424115ed44e5c83c2a901a0b6157a959079d7591d92106ffd3ada380";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
