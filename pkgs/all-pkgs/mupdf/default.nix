{ stdenv
, fetchurl

, curl
, freetype
, glfw
, harfbuzz
, jbig2dec
, libjpeg
, mujs
, openjpeg
, openssl
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  version = "1.9";
  name = "mupdf-${version}";

  src = fetchurl {
    url = "http://mupdf.com/downloads/archive/${name}-source.tar.gz";
    sha256 = "1776eb4368467c553ce78ec89c731ed84917c6c7ee0396b15d8739356c98e296";
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
    openssl
    xorg.libX11
    xorg.libXext
    xorg.xproto
    zlib
  ];

  preBuild = ''
    rm -rf thirdparty

    sed -i '/INSTALL_APPS/ s,$(MUJSTEST),,g' Makefile
    makeFlagsArray+=(
      "MUJS_CFLAGS= -I${mujs}/include"
      "MUJS_LIBS= -lmujs"
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
