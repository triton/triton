{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, curl
, freeglut
, freetype
, glu
, harfbuzz_lib
, jbig2dec
, libjpeg
, libx11
, libxext
, mujs
, opengl-dummy
, openjpeg
, openssl
, xorgproto
, zlib
}:

let
  version = "1.13.0";
in
stdenv.mkDerivation rec {
  name = "mupdf-${version}";

  src = fetchurl {
    url = "https://mupdf.com/downloads/archive/${name}-source.tar.xz";
    multihash = "Qmc427qqvKzzDi8bUKa4weMMyNCTNNcvYvSxsL8DqH3Fty";
    hashOutput = false;
    sha256 = "746698e0d5cd113bdcb8f65d096772029edea8cf20704f0d15c96cb5449a4904";
  };

  buildInputs = [
    curl
    freeglut
    freetype
    glu
    harfbuzz_lib
    jbig2dec
    libjpeg
    libx11
    libxext
    mujs
    opengl-dummy
    openjpeg
    openssl
    xorgproto
    zlib
  ];

  # WTF tar is broken without the `v` verbose option
  # No clue on this one
  preUnpack = ''
    _defaultUnpack() {
      xz -d <"$1" | tar x || true
    }
  '';

  postPatch = /* Remove any unused third party utils*/ ''
    rm -r thirdparty
  '';

  preBuild = ''
    makeFlagsArray+=(
      "MUJS_CFLAGS= -I${mujs}/include"
      "MUJS_LIBS= -lmujs"
      "HAVE_MUJS=yes"
      "build=release"
      "verbose=yes"
      "prefix=$out"
    )
  '';

  postInstall = ''
    mkdir -p "$out"/lib/pkgconfig
    ! test -e "$out"/lib/pkgconfig/mupdf.pc
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
    ! test -e "$out"/share/applications/mupdf.desktop
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

  meta = with lib; {
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
