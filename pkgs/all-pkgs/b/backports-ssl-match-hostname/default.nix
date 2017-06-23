{ stdenv
, buildPythonPackage
, fetchPyPi
, lib
, pythonAtLeast
}:

let
  version = "3.5.0.1";
in
buildPythonPackage rec {
  name = "backports-ssl-match-hostname-${version}";

  src = fetchPyPi {
    package = "backports.ssl_match_hostname";
    inherit version;
    sha256 = "502ad98707319f4a51fa2ca1c677bd659008d27ded9f6380c79e8932e38dcdf2";
  };

  # Backport of functionality from Python 3.5
  disabled = pythonAtLeast "3.5";
  doCheck = true;

  meta = with lib; {
    description = "The ssl.match_hostname() function from Python 3.5";
    homepage = http://bitbucket.org/brandon/backports.ssl_match_hostname;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
