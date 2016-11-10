{ stdenv
, asciidoc
, docbook_xml_dtd_45
, docbook-xsl
, fetchurl
, libxslt
, xmlto

, krb5_lib
, libsodium
, util-linux_lib
}:

let
  version = "4.2.0";
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "53b83bf0ee978931f76fa9cb46ad4affea65787264a5f3d140bc743412d0c117";
  };

  nativeBuildInputs = [
    asciidoc
    docbook_xml_dtd_45
    docbook-xsl
    libxslt
    xmlto
  ];

  buildInputs = [
    krb5_lib
    libsodium
    util-linux_lib
  ];

  configureFlags = [
    "--with-gssapi_krb5"
    "--with-libsodium"
    # "--with-pgm" # TODO: Implement
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      md5Url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
        + "MD5SUMS";
      sha1Url = "https://github.com/zeromq/libzmq/releases/download/"
        + "v${version}/SHA1SUMS";
      failEarly = true;
    };
  };

  meta = with stdenv.lib; {
    description = "The Intelligent Transport Layer";
    homepage = "http://www.zeromq.org";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
