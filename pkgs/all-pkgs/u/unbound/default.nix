{ stdenv
, fetchurl

, expat
, fstrm
, libevent
, openssl
, protobuf-c
}:

let
  tarballUrls = version: [
    "https://unbound.net/downloads/unbound-${version}.tar.gz"
  ];

  version = "1.6.1";
in
stdenv.mkDerivation rec {
  name = "unbound-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmXibvY97if5jMiYyzaEM6WJHMCbHQnuz2N1XbQZjjxheW";
    hashOutput = false;
    sha256 = "42df63f743c0fe8424aeafcf003ad4b880b46c14149d696057313f5c1ef51400";
  };

  buildInputs = [
    expat
    fstrm
    libevent
    openssl
    protobuf-c
  ];

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-pie"
    "--enable-relro-now"
    "--enable-dnstap"
    "--with-dnstap-socket-path=/run/dnstap.sock"
  ];

  preInstall = ''
    installFlagsArray+=("configfile=$out/etc/unbound/unbound.conf")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.6.1";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "EDFA A3F2 CA4E 6EB0 5681  AF8E 9F6F 1C2D 7E04 5F8D";
      inherit (src) outputHashAlgo;
      outputHash = "42df63f743c0fe8424aeafcf003ad4b880b46c14149d696057313f5c1ef51400";
    };
  };

  meta = with stdenv.lib; {
    description = "Validating, recursive, and caching DNS resolver";
    homepage = http://www.unbound.net;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
