{ stdenv
, buildPythonPackage
, fetchPyPi
, isPy3
, lib

, beautifulsoup
}:

let
  version = "0.4.1";
in
buildPythonPackage rec {
  name = "tvrage-${version}";

  src = fetchPyPi {
    package = "python-tvrage";
    inherit version;
    sha256 = "f8a530376c5cf1bc573d1945a8504c3394b228c731a3eff5100c705997a72063";
  };

  postPatch = /* Fix setup.py detection of beautifulsoup */ ''
    sed -i setup.py \
      -e 's/\["BeautifulSoup"\]/\["beautifulsoup4"\]/'
  '';

  buildInputs = [
    beautifulsoup
  ];

  disabled = isPy3;
  doCheck = true;

  meta = with lib; {
    description = "Client interface for tvrage.com's XML-based api feeds";
    homepage = https://github.com/ckreutzer/python-tvrage;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
