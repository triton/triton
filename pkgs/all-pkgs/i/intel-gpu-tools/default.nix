{ stdenv
, bison
, fetchurl
, flex
, lib
, meson
, ninja
, peg

, alsa-lib
, cairo
, glib
, kmod
, libdrm
, libpciaccess
, libunwind
, libx11
, libxext
, libxrandr
, libxv
, procps
, systemd_lib
, xorgproto
, zlib
}:

stdenv.mkDerivation rec {
  name = "intel-gpu-tools-1.22";

  src = fetchurl {
    url = "mirror://xorg/individual/app/${name}.tar.xz";
    hashOutput = false;
    sha256 = "3d66c1dc5110712ca4d22199b3ce9853f261be1690064edf87e69e5392e39a5c";
  };

  nativeBuildInputs = [
    bison
    flex
    meson
    ninja
    peg
  ];

  buildInputs = [
    cairo
    glib
    kmod
    libdrm
    libpciaccess
    libunwind
    libx11
    libxext
    libxrandr
    libxv
    procps
    systemd_lib
    xorgproto
    zlib
  ];

  postPatch = ''
    sed -i "/subdir('\(docs\|tests\|benchmarks\)')/d" meson.build
    sed -i 's,IGT_SRCDIR,"/no-such-path",g' lib/igt_core.h
  '';

  mesonFlags = [
    "-Duse-rpath=true"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "7759 65B8 5650 195A CE77  E18D 7370 055D B74C 2475";
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
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
