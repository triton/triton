{ stdenv
, fetchurl
, lib
, util-macros

, libpthread-stubs
, libxau
, libxdmcp
, pythonPackages
}:

stdenv.mkDerivation rec {
  name = "libxcb-1.13";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "188c8752193c50ff2dbe89db4554c63df2e26a2e47b0fa415a70918b5b851daa";
  };

  nativeBuildInputs = [
    pythonPackages.python
    util-macros
  ];

  buildInputs = [
    libpthread-stubs
    libxau
    libxdmcp
    pythonPackages.xcb-proto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-devel-docs"
    "--enable-composite"
    "--enable-damage"
    "--enable-dpms"
    "--enable-dri2"
    "--enable-dri3"
    "--enable-glx"
    "--enable-present"
    "--enable-randr"
    "--enable-record"
    "--enable-render"
    "--enable-resource"
    "--enable-screensaver"
    "--enable-shape"
    "--enable-shm"
    "--enable-sync"
    "--enable-xevie"
    "--enable-xfixes"
    "--enable-xfree86-dri"
    "--enable-xinerama"
    "--enable-xinput"
    "--enable-xkb"
    "--enable-xprint"
    "--enable-selinux"
    "--enable-xtest"
    "--enable-xv"
    "--enable-xvmc"
    "--without-doxygen"
    "--without-launchd"
    "--without-serverside-support"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Daniel Stone
        "A66D 805F 7C93 29B4 C5D8  2767 CCC4 F07F AC64 1EFF"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "The X C Binding (XCB) library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
