{ stdenv
, fetchurl

, krb5_lib
, libsodium
, util-linux_lib
}:

let
  version = "4.2.3";
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "8f1e2b2aade4dbfde98d82366d61baef2f62e812530160d2e6d0a5bb24e40bc0";
  };

  buildInputs = [
    krb5_lib
    libsodium
    util-linux_lib
  ];

  configureFlags = [
    "--with-libgssapi_krb5"
    "--with-libsodium"
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
