{ stdenv
, fetchurl

, freeglut
, giflib
, libjpeg
, libpng
, libtiff
, mesa
}:

stdenv.mkDerivation rec {
  name = "libwebp-${version}";
  version = "0.5.0";

  src = fetchurl {
    url = "http://downloads.webmproject.org/releases/webp/${name}.tar.gz";
    sha256 = "0x5jvwvrxq025srjbcjyzn47dgxbvg41sqdxf171zzrsc9xvplsw";
  };

  configureFlags = [
    "--enable-threading"
    "--enable-gl"
    "--enable-png"
    "--enable-jpeg"
    "--enable-tiff"
    "--enable-gif"
    # "--enable-aligned"
    # "--enable-swap-16bit-csp"
    # "--enable-experimental"
    "--enable-libwebpmux"
    "--enable-libwebpdemux"
    "--enable-libwebpdecoder"
  ];

  buildInputs = [
    freeglut
    giflib
    libjpeg
    libpng
    libtiff
    mesa
  ];

  meta = with stdenv.lib; {
    description = "Tools and library for the WebP image format";
    homepage = https://developers.google.com/speed/webp/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
