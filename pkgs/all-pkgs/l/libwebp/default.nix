{ stdenv
, fetchurl

, freeglut
, giflib
, libjpeg
, libpng
, libtiff
, mesa

, viewer ? false
}:

let
  inherit (stdenv.lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "libwebp-0.5.2";

  src = fetchurl {
    url = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${name}.tar.gz";
    sha256 = "b75310c810b3eda222c77f6d6c26b061240e3d9060095de44b2c1bae291ecdef";
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
    giflib
    libjpeg
    libpng
    libtiff
  ] ++ optionals viewer [
    freeglut
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
