{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXv-1.0.11";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "d26c13eac99ac4504c532e8e76a1c8e4bd526471eb8a0a4ff2a88db60cb0b088";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    "--disable-lint-library"
    "--without-lint"
  ];

  passthru = {
    srcVerification = fetchurl {
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprints = [
        # Matthieu Herrb
        "C41C 985F DCF1 E536 4576  638B 6873 93EE 37D1 28F8"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "Xvideo extension library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
