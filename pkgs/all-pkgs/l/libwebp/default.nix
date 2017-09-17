{ stdenv
, fetchurl
, lib

, freeglut
, giflib
, libjpeg
, libpng
, libtiff
, opengl-dummy

, viewer ? false
}:

let
  inherit (lib)
    optionals;
in
stdenv.mkDerivation rec {
  name = "libwebp-0.6.0";

  src = fetchurl {
    url = "https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${name}.tar.gz";
    sha256 = "c928119229d4f8f35e20113ffb61f281eda267634a8dc2285af4b0ee27cf2b40";
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
    "--enable-libwebpextras"
  ];

  buildInputs = [
    giflib
    libjpeg
    libpng
    libtiff
  ] ++ optionals viewer [
    freeglut
    opengl-dummy
  ];

  meta = with lib; {
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
