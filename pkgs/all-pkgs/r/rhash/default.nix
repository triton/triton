{ stdenv
, fetchurl

, openssl
}:

let
  version = "1.3.7";
in
stdenv.mkDerivation rec {
  name = "rhash-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/rhash/rhash/${version}/${name}-src.tar.gz";
    hashOutput = false;
    sha256 = "a2441b7a04ae554ddd3eafcf50365c787b012e35ee6402eb6705d9cd4b8dfa65";
  };

  buildInputs = [
    openssl
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--enable-openssl"
    "--disable-openssl-runtime"
  ];

  preInstall = ''
    installFlagsArray+=("SYSCONFDIR=$out/etc")
  '';

  installTargets = [
    "install"
    "install-pkg-config"
    "install-lib-headers"
    "install-lib-so-link"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.asc") src.urls;
        pgpKeyFingerprint = "2875 F6B1 C2D2 7A4F 0C8A  F60B 2A71 4497 E373 63AE";
      };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
