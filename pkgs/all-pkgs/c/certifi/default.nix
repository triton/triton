{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "2018.4.16";
in
buildPythonPackage rec {
  name = "certifi-${version}";

  src = fetchPyPi {
    package = "certifi";
    inherit version;
    sha256 = "13e698f54293db9f89122b0581843a782ad0934a4fe0172d2a980ba77fc61bb7";
  };

  meta = with lib; {
    description = "Python package for providing Mozilla's CA Bundle";
    homepage = http://certifi.io/;
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
