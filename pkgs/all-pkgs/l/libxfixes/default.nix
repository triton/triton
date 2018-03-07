{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXfixes-5.0.3";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "de1cd33aff226e08cefd0e6759341c2c8e8c9faf8ce9ac6ec38d43e287b22ad6";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        "C41C 985F DCF1 E536 4576  638B 6873 93EE 37D1 28F8"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "X-Fixes extension";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
