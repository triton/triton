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

let
  rev = "7d4360c64d94de53d907f13ca99837285e972ec6";
  version = "2018-02-27";
in
stdenv.mkDerivation rec {
  name = "xdg-utils-${version}";

  src = fetchurl {
    name = "${name}.tar.gz";
    url = "https://cgit.freedesktop.org/xdg/xdg-utils/snapshot/${rev}.tar.gz";
    multihash = "QmWgBkZtmwisnmDut85mWXP6MutN34i6VHJgWtj1V2wbvC";
    sha256 = "7933aaea46227c70adcaab75d9360caa251f4589be6e56268eeee157c22fb089";
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
