{ stdenv
, buildPythonPackage
, fetchPyPi
}:

buildPythonPackage rec {
  name = "beautifulsoup-${version}";
  version = "4.4.1";

  src = fetchPyPi {
    package = "beautifulsoup4";
    inherit version;
    sha256 = "87d4013d0625d4789a4f56b8d79a04d5ce6db1152bb65f1d39744f7709a366b4";
  };

  doCheck = true;

  meta = with stdenv.lib; {
    description = "HTML/XML parser";
    homepage = http://www.crummy.com/software/BeautifulSoup/;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
