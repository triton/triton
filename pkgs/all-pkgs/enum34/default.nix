{ stdenv
, buildPythonPackage
, fetchurl
, fetchzip
}:

buildPythonPackage rec {
  name = "enum34-${version}";
  version = "1.1.4";

  /* pypi botched this package and thinks 1.1.5 exists already
  src = fetchurl {
    url = "mirror://pypi/e/enum34/${name}.tar.gz";
    sha256 = "865506c22462236b3a2e87a7d9587633e18470e7a93a79b594791de2d31e9bc8";
  };*/

  src = fetchzip {
    url = "https://bitbucket.org/stoneleaf/enum34/get/${version}.tar.bz2";
    sha256 = "652d7bcd794f8fdefbe59a5fff44a178f65cbe53e1f5b7eb6edadddd0e83ef8f";
  };

  meta = with stdenv.lib; {
    description = "Python 3.4 Enum backported to 2.4 through 3.3";
    homepage = https://bitbucket.org/stoneleaf/enum34;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
