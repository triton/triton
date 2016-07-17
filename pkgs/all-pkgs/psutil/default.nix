{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "psutil-${version}";
  version = "4.3.0";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "86197ae5978f216d33bfff4383d5cc0b80f079d09cf45a2a406d1abb5d0299f0";
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
