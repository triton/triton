{ stdenv
, fetchurl
, lib
, util-macros

, libxau
, libxdmcp
, python3Packages
}:

stdenv.mkDerivation rec {
  name = "libxcb-1.14";

  src = fetchurl {
    url = "mirror://xorg/individual/xcb/${name}.tar.xz";
    hashOutput = false;
    sha256 = "a55ed6db98d43469801262d81dc2572ed124edc3db31059d4e9916eb9f844c34";
  };

  nativeBuildInputs = [
    util-macros
    python3Packages.python
    python3Packages.xcb-proto
  ];

  buildInputs = [
    libxau
    libxdmcp
  ];

  configureFlags = [
    "--disable-devel-docs"
    "--enable-dri3"
    "--enable-xevie"
    "--enable-xprint"
    "--enable-selinux"
    "--without-launchd"
    "--with-serverside-support"
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
