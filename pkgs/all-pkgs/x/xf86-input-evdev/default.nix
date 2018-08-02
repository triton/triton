{ stdenv
, fetchurl
, lib
, util-macros

, libevdev
, libpciaccess
, mtdev
, systemd_lib
, xorgproto
, xorg-server
}:

stdenv.mkDerivation rec {
  name = "xf86-input-evdev-2.10.6";

  src = fetchurl {
    url = "mirror://xorg/individual/driver/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "8726073e81861bc7b2321e76272cbdbd33c7e1a121535a9827977265b9033ec0";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libevdev
    libpciaccess
    mtdev
    systemd_lib
    xorgproto
    xorg-server
  ];
  
  preConfigure = ''
    configureFlagsArray+=(
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
