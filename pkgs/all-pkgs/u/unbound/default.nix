{ stdenv
, fetchurl

, expat
, fstrm
, libevent
, libsodium
, openssl
, protobuf-c
, systemd_lib
}:

let
  tarballUrls = version: [
    "https://unbound.net/downloads/unbound-${version}.tar.gz"
  ];

  version = "1.6.6";
in
stdenv.mkDerivation rec {
  name = "unbound-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmevsSE8UcVDW3CnKqjZhrDp3JRqXx5DbKRZsgYRTHGu1L";
    hashOutput = false;
    sha256 = "972b14dc33093e672652a7b2b5f159bab2198b0fe9c9e1c5707e1895d4d4b390";
  };

  buildInputs = [
    expat
    fstrm
    libevent
    libsodium
    openssl
    protobuf-c
    systemd_lib
  ];

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--enable-pie"
    "--enable-relro-now"
    "--enable-subnet"
    "--enable-tfo-client"
    "--enable-tfo-server"
    "--enable-systemd"
    "--enable-dnstap"
    "--enable-dnscrypt"
    "--enable-cachedb"
    "--with-dnstap-socket-path=/run/dnstap.sock"
    "--with-pthreads"
  ];

  preInstall = ''
    installFlagsArray+=("configfile=$out/etc/unbound/unbound.conf")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.6.6";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "EDFA A3F2 CA4E 6EB0 5681  AF8E 9F6F 1C2D 7E04 5F8D";
      inherit (src) outputHashAlgo;
      outputHash = "972b14dc33093e672652a7b2b5f159bab2198b0fe9c9e1c5707e1895d4d4b390";
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
