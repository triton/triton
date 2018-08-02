{ stdenv
, fetchurl
, lib
, util-macros

, libevdev
, libpciaccess
, libx11
, libxi
, libxtst
, xorgproto
, xorg-server
}:

stdenv.mkDerivation rec {
  name = "xf86-input-synaptics-1.9.1";

  src = fetchurl {
    url = "mirror://xorg/individual/driver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "7af83526eff1c76e8b9e1553b34245c203d029028d8044dd9dcf71eef1001576";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libevdev
    libpciaccess
    libx11
    libxi
    libxtst
    xorgproto
    xorg-server
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-xorg-conf-dir=$out/share/X11/xorg.conf.d"
      "--with-sdkdir=$out/include/xorg"
    )
  '';

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Peter Hutterer
        "3C2C 43D9 447D 5938 EF45  51EB E23B 7E70 B467 F0BF"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
