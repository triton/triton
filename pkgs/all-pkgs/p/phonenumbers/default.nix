{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "8.8.6";
in
buildPythonPackage {
  name = "phonenumbers-${version}";

  src = fetchPyPi {
    package = "phonenumbers";
    inherit version;
    sha256 = "ab1fa853350dde91be672192b427169b29e3348c236e46ad7a757e4ac8163c8c";
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
