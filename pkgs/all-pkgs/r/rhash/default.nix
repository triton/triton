{ stdenv
, fetchurl
}:

let
  version = "1.3.5";
in
stdenv.mkDerivation rec {
  name = "rhash-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/rhash/rhash/${version}/${name}-src.tar.gz";
    hashOutput = false;
    sha256 = "98e0688acae29e68c298ffbcdbb0f838864105f9b2bd8857980664435b1f1f2e";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  buildFlags = [
    "build-shared"
    "lib-shared"
  ];

  preInstall = ''
    grep '$(DESTDIR)/etc' Makefile
    sed -i 's,$(DESTDIR)/etc,$(DESTDIR)/$(PREFIX)/etc,g' Makefile
    echo 'install-nix:' >>Makefile
    echo $'\t' '+$(MAKE) -C librhash install-headers' >>Makefile
    echo $'\t' '+$(MAKE) -C librhash install-so-link' >>Makefile
  '';

  installTargets = [
    "install-lib-shared"
    "install-nix"
    "install-shared"
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
