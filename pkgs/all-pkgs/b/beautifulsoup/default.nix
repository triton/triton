{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, html5lib
, lxml
}:

let
  version = "4.7.1";
in
buildPythonPackage rec {
  name = "beautifulsoup-${version}";

  src = fetchPyPi {
    package = "beautifulsoup4";
    inherit version;
    sha256 = "945065979fb8529dd2f37dbb58f00b661bdbcbebf954f93b32fdf5263ef35348";
  };

  propagatedBuildInputs = [
    html5lib
    lxml
  ];

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
