{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "tmdb3-${version}";
  version = "0.7.2";

  src = fetchPyPi {
    package = "tmdb3";
    inherit version;
    sha256 = "9b6e043b8a65d159e7fc8f720badc7ffee5109296e38676c107454e03a895983";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "TheMovieDB.org APIv3 interface";
    homepage = https://pypi.python.org/pypi/tmdb3;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
