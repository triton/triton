{ stdenv
, fetchurl

, krb5_lib
, libsodium
, libunwind
}:

let
  version = "4.3.1";
in
stdenv.mkDerivation rec {
  name = "zeromq-${version}";

  src = fetchurl {
    url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
      + "${name}.tar.gz";
    hashOutput = false;
    sha256 = "bcbabe1e2c7d0eec4ed612e10b94b112dd5f06fcefa994a0c79a45d835cd21eb";
  };

  buildInputs = [
    krb5_lib
    libsodium
    libunwind
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
      failEarly = true;
      fullOpts = {
        md5Url = "https://github.com/zeromq/libzmq/releases/download/v${version}/"
          + "MD5SUMS";
        sha1Url = "https://github.com/zeromq/libzmq/releases/download/"
          + "v${version}/SHA1SUMS";
      };
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
