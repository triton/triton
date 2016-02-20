{ stdenv
, docbook_xml_dtd_412
, docbook_xsl
, fetchurl
, libxslt
, xmlto
, w3m-batch

, coreutils
, file
, gnugrep
, gnused
}:

stdenv.mkDerivation rec {
  name = "xdg-utils-${version}";
  rev = "c7ecf26e036c7a5f8a921d12c7efe1435f3e996b";
  version = "2016-02-16";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "https://cgit.freedesktop.org/xdg/xdg-utils/snapshot/${rev}.tar.gz";
    sha256 = "0sncry55w7xqlyb8l3wc2cv4w52wws939855cfq26pnf5xx2vg1n";
  };

  buildInputs = [
    libxslt
    docbook_xml_dtd_412
    docbook_xsl
    xmlto
    w3m-batch
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
      i686-linux
      ++ x86_64-linux;
  };
}
