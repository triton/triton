{ stdenv
, buildPythonPackage
, lib
, fetchPyPi
}:

let
  version = "5.4.1";
in
buildPythonPackage rec {
  name = "psutil-${version}";

  src = fetchPyPi {
    package = "psutil";
    inherit version;
    sha256 = "42e2de159e3c987435cb3b47d6f37035db190a1499f3af714ba7af5c379b6ba2";
  };

  meta = with lib; {
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
