{ stdenv
, buildPythonPackage
, fetchurl
}:

buildPythonPackage rec {
  name = "backports.ssl_match_hostname-3.5.0.1";

  src = fetchurl {
    url = "mirror://pypi/b/backports.ssl_match_hostname/${name}.tar.gz";
    sha256 = "502ad98707319f4a51fa2ca1c677bd659008d27ded9f6380c79e8932e38dcdf2";
  };

  meta = with stdenv.lib; {
    description = "he ssl.match_hostname() function from Python 3.5";
    homepage = http://bitbucket.org/brandon/backports.ssl_match_hostname;
    license = licenses.free; # python sfl
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
