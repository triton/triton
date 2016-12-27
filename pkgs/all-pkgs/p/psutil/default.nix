{ stdenv
, buildPythonPackage
, fetchPyPi
}:

let
  version = "5.0.1";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "9d8b7f8353a2b2eb6eb7271d42ec99d0d264a9338a37be46424d56b4e473b39e";
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
