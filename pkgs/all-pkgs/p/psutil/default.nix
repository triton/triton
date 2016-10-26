{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "4.4.0";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "f4da111f473dbf7e813e6610aec1329000536aea5e7d7e73ed20bc42cfda7ecc";
  };

  meta = with stdenv.lib; {
    description = "A process and system utilities module for Python";
    homepage = https://github.com/giampaolo/psutil/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
