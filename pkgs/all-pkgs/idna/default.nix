{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "2.1";
in
buildPythonPackage {
  name = "idna-${version}";

  src = fetchPyPi {
    package = "idna";
    inherit version;
    sha256 = "ed36f281aebf3cd0797f163bb165d84c31507cedd15928b095b1675e2d04c676";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
