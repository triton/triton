{ stdenv
, docbook_xml_dtd_412
, docbook-xsl
, fetchurl
, libxslt
, xmlto
, w3m

, coreutils
, file
, gnugrep
, gnused
}:

let
  rev = "338f54e0dbf3d9e9583f34c9dde194c39ba0b4e8";
  version = "2016-06-10";
in
stdenv.mkDerivation rec {
  name = "xdg-utils-${version}";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "https://cgit.freedesktop.org/xdg/xdg-utils/snapshot/${rev}.tar.gz";
    sha256 = "541ba6e0b8c090f387ed6858d7da202dbbcf5d7701d257d76ebaeea538bef3b7";
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

  meta = with stdenv.lib; {
    description = "Desktop integration utilities";
    homepage = http://portland.freedesktop.org/wiki/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
