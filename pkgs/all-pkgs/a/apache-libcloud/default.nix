{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
}:

let
  version = "1.5.0";
in
buildPythonPackage rec {
  name = "apache-libcloud-${version}";

  src = fetchPyPi {
    package = "apache-libcloud";
    inherit version;
    type = ".tar.bz2";
    sha256 = "ea3dd7825e30611e5a018ab18107b33a9029097d64bd8b39a87feae7c2770282";
  };

  meta = with lib; {
    description = "Python library for interacting with cloud service providers";
    homepage = https://libcloud.apache.org;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
