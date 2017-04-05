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
  version = "4.2.1";
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "27d1e82a099228ee85a7ddb2260f40830212402c605a4a10b5e5498a7e0e9d03";
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
