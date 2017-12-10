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
    version = 4;
    owner = "asciidoc";
    repo = "asciidoc";
    rev = version;
    sha256 = "6534194fe2de087eb6e9fb3ab6ac393e3690380ee9ec8a18b9dc46171a0e3691";
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
