{ stdenv
, fetchurl

, openssl
}:

let
  version = "1.3.6";
in
stdenv.mkDerivation rec {
  name = "rhash-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/rhash/rhash/${version}/${name}-src.tar.gz";
    hashOutput = false;
    sha256 = "964df972b60569b5cb35ec989ced195ab8ea514fc46a74eab98e86569ffbcf92";
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

    ! grep -q 'install-headers' Makefile
    echo 'install-nix:' >>Makefile
    echo $'\t' '+$(MAKE) -C librhash install-headers' >>Makefile
    echo $'\t' '+$(MAKE) -C librhash install-so-link' >>Makefile
  '';

  installTargets = [
    "install"
    "install-pkg-config"
    "install-nix"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "2875 F6B1 C2D2 7A4F 0C8A  F60B 2A71 4497 E373 63AE";
      inherit (src) urls outputHash outputHashAlgo;
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
