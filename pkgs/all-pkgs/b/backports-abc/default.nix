{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonAtLeast
}:

let
  version = "0.5";
in
buildPythonPackage rec {
  name = "backports_abc-${version}";

  src = fetchPyPi {
    package = "backports_abc";
    inherit version;
    sha256 = "033be54514a03e255df75c5aee8f9e672f663f93abb723444caec8fe43437bde";
  };

  # Backport of Python 3.5 "collections.abc"
  disabled = pythonAtLeast "3.5";

  meta = with lib; {
    description = "Backport of recent additions to the 'collections.abc' module";
    homepage = https://github.com/cython/backports_abc;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
