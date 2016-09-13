{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "psutil-${version}";
  version = "4.3.1";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "38f74182fb9e15cafd0cdf0821098a95cc17301807aed25634a18b66537ba51b";
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
