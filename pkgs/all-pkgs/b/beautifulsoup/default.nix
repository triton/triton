{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k

, html5lib
, lxml
}:

let
  inherit (stdenv.lib)
    optionals;

  version = "4.5.1";
in
buildPythonPackage rec {
  name = "beautifulsoup-${version}";

  src = fetchPyPi {
    package = "beautifulsoup4";
    inherit version;
    sha256 = "3c9474036afda9136aac6463def733f81017bf9ef3510d25634f335b0c87f5e1";
  };

  propagatedBuildInputs = [
    html5lib
    lxml
  ];

  # Not all tests have been converted to Python 3
  doCheck = !isPy3k;

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
