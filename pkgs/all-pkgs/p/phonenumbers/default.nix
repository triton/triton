{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "8.4.0";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "4b6d747c67957359bc02d0e93b5e809d234114b7a50b2c070a7ba87cda1305b0";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
