{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libxkbfile-1.0.9";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "51817e0530961975d9513b773960b4edd275f7d5c72293d5a151ed4f42aeb16a";
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
        # Alan Coopersmith
        "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E"
      ];
      failEarly = true;
    };
  };

  meta = with lib; {
    description = "XKB file handling routines";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
