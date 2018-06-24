{ stdenv
, fetchurl

, expat
, fstrm
, hiredis
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

  version = "1.7.3";
in
stdenv.mkDerivation rec {
  name = "unbound-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    multihash = "QmeoDAkmudmjJ5sTWThoKFpBX3gfsCiTPsgb6axZdJu2n8";
    hashOutput = false;
    sha256 = "c11de115d928a6b48b2165e0214402a7a7da313cd479203a7ce7a8b62cba602d";
  };

  buildInputs = [
    expat
    fstrm
    hiredis
    libevent
    libsodium
    openssl
    protobuf-c
    systemd_lib
  ];

  configureFlags = [
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
    "--enable-ipsecmod"
    "--with-ssl=${openssl}"
    "--with-libexpat=${expat}"
    "--with-libevent=${libevent}"
    "--with-libhiredis=${hiredis}"
    "--with-dnstap-socket-path=/run/dnstap.sock"
    "--with-pthreads"
  ];

  preInstall = ''
    installFlagsArray+=("configfile=$out/etc/unbound/unbound.conf")
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.7.3";
      pgpsigUrls = map (n: "${n}.asc") urls;
      pgpKeyFingerprint = "EDFA A3F2 CA4E 6EB0 5681  AF8E 9F6F 1C2D 7E04 5F8D";
      inherit (src) outputHashAlgo;
      outputHash = "c11de115d928a6b48b2165e0214402a7a7da313cd479203a7ce7a8b62cba602d";
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
