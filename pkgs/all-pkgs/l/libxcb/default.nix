{ stdenv
, fetchurl
, lib
, util-macros

, libpthread-stubs
, libxau
, libxdmcp
, python3Packages
}:

stdenv.mkDerivation rec {
  name = "libxcb-1.13.1";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "a89fb7af7a11f43d2ce84a844a4b38df688c092bf4b67683aef179cdf2a647c4";
  };

  nativeBuildInputs = [
    util-macros
    python3Packages.python
    python3Packages.xcb-proto
  ];

  buildInputs = [
    libpthread-stubs
    libxau
    libxdmcp
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-devel-docs"
    "--enable-dri3"
    "--enable-xevie"
    "--enable-xprint"
    "--enable-selinux"
    "--without-doxygen"
    "--without-launchd"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprints = [
          # Daniel Stone
          "A66D 805F 7C93 29B4 C5D8  2767 CCC4 F07F AC64 1EFF"
        ];
      };
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
