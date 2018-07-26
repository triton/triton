{ stdenv
, docbook_xml_dtd_412
, docbook-xsl
, fetchurl
, lib
, libxslt
, xmlto
, w3m

, coreutils
, file
, gnugrep
, gnused
}:

stdenv.mkDerivation rec {
  name = "xdg-utils-1.1.3";

  src = fetchurl {
    url = "https://portland.freedesktop.org/download/${name}.tar.gz";
    multihash = "QmfVZz8B54tQZNrVKR6RD1NY8PnCEjEjkeS4u2gmrkkRu3";
    sha256 = "d798b08af8a8e2063ddde6c9fa3398ca81484f27dec642c5627ffcaa0d4051d9";
  };

  buildInputs = [
    libxslt
    docbook_xml_dtd_412
    docbook-xsl
    xmlto
    w3m
  ];

  postInstall = ''
    for item in $out/bin/* ; do
      sed -i "$item" \
        -e 's|cut |${coreutils}/bin/cut |' \
        -e 's|sed |${gnused}/bin/sed |' \
        -e 's|egrep |${gnugrep}/bin/egrep |' \
        -re "s#([^e])grep #\1${gnugrep}/bin/grep #g" \
        -e 's|which |type -P |' \
        -e 's|/usr/bin/file|${file}/bin/file|'
    done
  '';

  meta = with lib; {
    description = "Desktop integration utilities";
    homepage = http://portland.freedesktop.org/wiki/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
