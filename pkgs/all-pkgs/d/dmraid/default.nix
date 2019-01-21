{ stdenv
, fetchurl

, lvm2
}:

stdenv.mkDerivation rec {
  name = "dmraid-1.0.0.rc16-3";

  src = fetchurl {
    url = "https://people.redhat.com/~heinzm/sw/dmraid/src/${name}.tar.bz2";
    multihash = "QmanUgfoBVym62J81wox6pe6XkszyFXJ24fnoGiuBZZDfC";
    hashOutput = false;
    sha256 = "93421bd169d71ff5e7d2db95b62b030bfa205a12010b6468dcdef80337d6fbd8";
  };

  buildInputs = [
    lvm2
  ];

  prePatch = ''
    cd */*
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-led"
    "--enable-intel_led"
  ];

  # Parallel make is broken
  buildParallel = false;
  installParallel = false;

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Urls = map (n: "${n}.md5.sum") src.urls;
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
