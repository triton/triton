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
  version = "4.2.2";
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "5b23f4ca9ef545d5bd3af55d305765e3ee06b986263b31967435d285a3e6df6b";
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
