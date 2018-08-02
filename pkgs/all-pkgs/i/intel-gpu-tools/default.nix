{ stdenv
, bison
, docutils
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
, openssl
, procps
, systemd_lib
, xorgproto
, zlib
}:

let
  version = "1.23";
in
stdenv.mkDerivation rec {
  name = "intel-gpu-tools-${version}";

  src = fetchurl {
    url = "mirror://xorg/individual/app/igt-gpu-tools-${version}.tar.xz";
    hashOutput = false;
    sha256 = "4d4b086c513bace5c23d0889de3f42ac3ebd3d968c64dedae6e28e006a499ad0";
  };

  nativeBuildInputs = [
    bison
    docutils
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
    openssl
    procps
    systemd_lib
    xorgproto
    zlib
  ];

  postPatch = ''
    # Don't build benchmarks
    grep -q "subdir('benchmarks')" meson.build
    sed -i "/subdir('benchmarks')/d" meson.build

    # Fix build impurities
    grep -q 'IGT_SRCDIR' lib/igt_core.h
    sed -i 's,IGT_SRCDIR,"/no-such-path",g' lib/igt_core.h

    # Fix name of rst2man executable
    grep -q "'rst2man'" man/meson.build
    sed -i "s#'rst2man'#'rst2man.py'#" man/meson.build
    grep -q '^rst2man ' man/rst2man.sh
    sed -i 's#^rst2man #rst2man.py #' man/rst2man.sh

    patchShebangs man/rst2man.sh
  '';

  mesonFlags = [
    "-Dbuild_tests=false"
    "-Dbuild_man=true"
    "-Dbuild_docs=false"
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
