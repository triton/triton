{ stdenv
, autoreconfHook
, docbook_xml_dtd_45
, docbook-xsl
, fetchFromGitHub
, libxml2
, libxslt

, python2Packages
}:

let
  version = "8.6.10";
in
stdenv.mkDerivation rec {
  name = "asciidoc-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "asciidoc";
    repo = "asciidoc";
    rev = version;
    sha256 = "0f90e25f46d1ba2c5b12a2db896c80a1d82c145606ce536dd9766b814b7be929";
  };

  nativeBuildInputs = [
    autoreconfHook
    docbook_xml_dtd_45
    docbook-xsl
    libxml2
    libxslt
  ];

  buildInputs = [
    python2Packages.python
  ];

  postPatch = ''
    patchShebangs asciidoc.py
  '';

  meta = with stdenv.lib; {
    description = "A plain text human readable/writable document format";
    homepage = http://asciidoc.org/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
