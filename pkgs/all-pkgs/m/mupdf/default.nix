{ stdenv
, fetchTritonPatch
, fetchurl

, curl
, freetype
, glfw
, harfbuzz
, jbig2dec
, libjpeg
, mujs
, openjpeg
, openssl_1-0-2
, xorg
, zlib
}:

let
  version = "1.11";
in
stdenv.mkDerivation rec {
  name = "mupdf-${version}";

  src = fetchurl {
    url = "https://mupdf.com/downloads/archive/${name}-source.tar.gz";
    sha256 = "209474a80c56a035ce3f4958a63373a96fad75c927c7b1acdc553fc85855f00a";
  };

  buildInputs = [
    curl
    freetype
    glfw
    harfbuzz
    jbig2dec
    libjpeg
    mujs
    openjpeg
    openssl_1-0-2
    xorg.libX11
    xorg.libXext
    xorg.xproto
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "10ac760ba2be89414f80c09f12081f311032a4d8";
      file = "m/mupdf/fix-openjpeg.patch";
      sha256 = "899ca42045806f69919929c2af1921868c053441648524212aa386c7f14bae4f";
    })
  ];

  preBuild = ''
    rm -rf thirdparty

    sed -i '/INSTALL_APPS/ s,$(MUJSTEST),,g' Makefile
    makeFlagsArray+=(
      "MUJS_CFLAGS= -I${mujs}/include"
      "MUJS_LIBS= -lmujs"
      "HAVE_MUJS=yes"
      "build=release"
      "verbose=yes"
      "prefix=$out"
    )

    sed -e "s/libopenjpeg1/libopenjp2/" -i Makerules
  '';

  postInstall = ''
    mkdir -p "$out/lib/pkgconfig"
    cat >"$out/lib/pkgconfig/mupdf.pc" <<EOF
    prefix=$out
    libdir=$out/lib
    includedir=$out/include

    Name: mupdf
    Description: Library for rendering PDF documents
    Requires: freetype2 libopenjp2 libcrypto
    Version: ${version}
    Libs: -L$out/lib -lmupdf
    Cflags: -I$out/include
    EOF

    mkdir -p $out/share/applications
    cat > $out/share/applications/mupdf.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=mupdf
    Comment=PDF viewer
    Exec=$out/bin/mupdf-x11 %f
    Terminal=false
    EOF
  '';

  meta = with stdenv.lib; {
    homepage = http://mupdf.com/;
    description = "Lightweight PDF viewer and toolkit written in portable C";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
