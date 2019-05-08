{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, freeglut
, freetype
, glu
, harfbuzz_lib
, jbig2dec
, libjpeg
, libx11
, libxext
, opengl-dummy
, openjpeg
, openssl
, xorgproto
, zlib
}:

let
  version = "1.15.0";
in
stdenv.mkDerivation rec {
  name = "mupdf-${version}";

  src = fetchurl {
    url = "https://mupdf.com/downloads/archive/${name}-source.tar.xz";
    multihash = "QmP661iM4eksoWU2sasD8u5mNktHhFKRdq4RQwTgBFMa6U";
    hashOutput = false;
    sha256 = "565036cf7f140139c3033f0934b72e1885ac7e881994b7919e15d7bee3f8ac4e";
  };

  buildInputs = [
    freeglut
    freetype
    glu
    harfbuzz_lib
    jbig2dec
    libjpeg
    libx11
    libxext
    opengl-dummy
    openjpeg
    openssl
    xorgproto
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "0d671ea5f3321a13a8c23e5961c86ab115505fdd";
      file = "m/mupdf/0001-jmemecust-Fix-for-new-libjpeg.patch";
      sha256 = "d734114c714ed04e51ca87e42bd42a2b8002c251a67bde5a9827a1eaa4504c1d";
    })
  ];

  postPatch = /* Keep lcms2art since it's special for mupdf */ ''
    mkdir -p thirdparty-keep
    mv thirdparty/lcms2 thirdparty-keep
    mv thirdparty/mujs thirdparty-keep
  '' + /* Remove any unused third party utils*/ ''
    rm -r thirdparty
    mv thirdparty-keep thirdparty
  '';

  NIX_CFLAGS_COMPILE = "-I${harfbuzz_lib}/include/harfbuzz " +
    "-I${openjpeg}/include/openjpeg-${openjpeg.channel}";

  preBuild = ''
    makeFlagsArray+=(
      "USE_SYSTEM_FREETYPE=yes"
      "USE_SYSTEM_HARFBUZZ=yes"
      "USE_SYSTEM_JBIG2DEC=yes"
      "USE_SYSTEM_LIBJPEG=yes"
      "USE_SYSTEM_OPENJPEG=yes"
      "USE_SYSTEM_ZLIB=yes"
      "USE_SYSTEM_GLUT=yes"
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha1Confirm = "dc5b40405b9a497e37370e26b2a8b115c944fe8a";
      };
    };
  };

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
