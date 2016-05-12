{ stdenv
, fetchurl
, pythonPackages

, libxml2
}:

stdenv.mkDerivation rec {
  name = "itstool-2.0.2";

  src = fetchurl rec {
    url = "http://files.itstool.org/itstool/${name}.tar.bz2";
    sha256Url = "${url}.sha256sum";
    sha256 = "bf909fb59b11a646681a8534d5700fec99be83bb2c57badf8c1844512227033a";
  };

  nativeBuildInputs = [
    pythonPackages.python
    pythonPackages.wrapPython
  ];

  buildInputs = [
    libxml2
  ];

  pythonPath = [
    libxml2
  ];

  preFixup = ''
    wrapPythonPrograms $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = http://itstool.org/;
    description = "XML to PO and back again";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
