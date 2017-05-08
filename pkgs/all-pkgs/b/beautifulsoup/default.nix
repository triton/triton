{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3k
, lib

, html5lib
, lxml
}:

let
  inherit (lib)
    optionals;

  version = "4.6.0";
in
buildPythonPackage rec {
  name = "beautifulsoup-${version}";

  src = fetchPyPi {
    package = "beautifulsoup4";
    inherit version;
    sha256 = "808b6ac932dccb0a4126558f7dfdcf41710dd44a4ef497a0bb59a77f9f078e89";
  };

  propagatedBuildInputs = [
    html5lib
    lxml
  ];

  # Not all tests have been converted to Python 3
  doCheck = !isPy3k;

  meta = with lib; {
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
