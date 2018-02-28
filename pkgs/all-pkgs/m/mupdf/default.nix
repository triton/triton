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
, openssl_1-0-2
, xproto
, zlib
}:

let
  version = "1.12.0";
in
stdenv.mkDerivation rec {
  name = "mupdf-${version}";

  src = fetchurl {
    url = "https://mupdf.com/downloads/archive/${name}-source.tar.xz";
    multihash = "QmckdELFTNVgMdvRdvcpTBCMeqYALcPnH1CGkpzE1Y2xfF";
    sha256 = "577b3820c6b23d319be91e0e06080263598aa0662d9a7c50af500eb6f003322d";
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
    openssl_1-0-2
    xproto
    zlib
  ];

  # WTF tar is broken without the `v` verbose option
  # No clue on this one
  preUnpack = ''
    _defaultUnpack() {
      xz -d <"$1" | tar xv
    }
  '';

  patches = [
    (fetchTritonPatch {
      rev = "21df51a39447ab99518058ddb37e245af246f15c";
      file = "m/mupdf/fix-openjpeg.patch";
      sha256 = "6a9088440cf12362b4292274e8eab8f509dd0b599a0ef548a4cc36d533c410f1";
    })
  ];

  postPatch = /* Remove any unused third party utils*/ ''
    rm -r thirdparty
  '' + /* Remove test junk from the build */ ''
    sed -i '/INSTALL_APPS/ s,$(MUJSTEST),,g' Makefile
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
