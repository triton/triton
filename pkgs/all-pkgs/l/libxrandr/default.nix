{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, libxrender
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libXrandr-1.5.1";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "1ff9e7fa0e4adea912b16a5f0cfa7c1d35b0dcda0e216831f7715c8a3abcf51a";
  };

  nativeBuildInputs = [
    util-macros
  ];

  buildInputs = [
    libx11
    libxext
    libxrender
    xorgproto
  ];

  configureFlags = [
    "--enable-selective-werror"
    "--disable-strict-compilation"
    #"--enable-malloc0returnsnull"
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
    description = "X Resize and Rotate Extension C Library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
