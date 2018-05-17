{ stdenv
, fetchurl
, lib
, util-macros

, libx11
, libxext
, xorgproto
}:

stdenv.mkDerivation rec {
  name = "libdmx-1.1.4";

  src = fetchurl {
    url = "mirror://xorg/individual/lib/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "253f90005d134fa7a209fbcbc5a3024335367c930adf0f3203e754cf32747243";
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
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "4A19 3C06 D35E 7C67 0FA4  EF0B A2FB 9E08 1F2D 130E";
      inherit (src)
        outputHash
        outputHashAlgo
        urls;
    };
  };

  meta = with lib; {
    description = "X.org libdmx library";
    homepage = https://xorg.freedesktop.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
