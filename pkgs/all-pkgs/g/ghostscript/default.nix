{ stdenv
, fetchurl
, fetchTritonPatch

, cups
, dbus
, fontconfig
, freetype
, ijs
, jbig2dec
, lcms2
, libidn
, libjpeg
, libpaper
, libpng
, zlib
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "9.21";
  versionNoP = replaceChars ["."] [""] version;

  fonts = stdenv.mkDerivation {
    name = "ghostscript-fonts";

    srcs = [
      (fetchurl {
        url = "mirror://sourceforge/gs-fonts/gs-fonts/8.11%20(base%2035,%20GPL)/ghostscript-fonts-std-8.11.tar.gz";
        sha256 = "00f4l10xd826kak51wsmaz69szzm2wp8a41jasr4jblz25bg7dhf";
      })
      (fetchurl {
        url = "mirror://gnu/ghostscript/gnu-gs-fonts-other-6.0.tar.gz";
        sha256 = "1cxaah3r52qq152bbkiyj2f7dx1rf38vsihlhjmrvzlr8v6cqil1";
      })
      # ... add other fonts here
    ];

    installPhase = ''
      mkdir "$out"
      mv -v * "$out/"
    '';
  };

  baseUrl = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${versionNoP}";
in
stdenv.mkDerivation rec {
  name = "ghostscript-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "2be1d014888a34187ad4bbec19ab5692cc943bd1cb14886065aeb43a3393d053";
  };

  outputs = [
    "out"
    "doc"
  ];

  buildInputs = [
    cups
    dbus
    fontconfig
    freetype
    ijs
    jbig2dec
    lcms2
    libidn
    libjpeg
    libpaper
    libpng
    zlib
  ];

  NIX_ZLIB_INCLUDE = "${zlib}/include";

  patches = [
    (fetchTritonPatch {
      rev = "9e45913651939a22fb58254b2482ae4dcb4c8d56";
      file = "g/ghostscript/CVE-2016-8602.patch";
      sha256 = "d48abd753695111b8b19b34c7590c8ed27b2c678575ac34f55e406b05bac0023";
    })
    (fetchTritonPatch {
      rev = "16e1e82d413e33a3a46976f64c275c58a7dc3928";
      file = "ghostscript/urw-font-files.patch";
      sha256 = "1f7e0e309802c4400a31eaadbdd4eb89c63db848f867891119156ce2cffd5c89";
    })
  ];

  postPatch = ''
    rm -r freetype jbig2dec jpeg lcms2 libpng tiff zlib ijs

    sed "s@if ( test -f \$(INCLUDE)[^ ]* )@if ( true )@; s@INCLUDE=/usr/include@INCLUDE=/no-such-path@" -i base/unix-aux.mak
    sed "s@^ZLIBDIR=.*@ZLIBDIR=${zlib}/include@" -i configure.ac
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--with-cups-serverbin=$out/lib/cups"
      "--with-cups-serverroot=$out/etc/cups"
      "--with-cups-datadir=$out/share/cups"
    )
  '';

  configureFlags = [
    "--with-system-libtiff"
    "--enable-fontconfig"
    "--enable-freetype"
    "--enable-dynamic"
    "--enable-cups"
  ];

  # don't build/install statically linked bin/gs
  buildFlags = [
    "so"
  ];

  installTargets = [
    "soinstall"
  ];

  postInstall = ''
    ln -s gsc "$out"/bin/gs

    cp -r Resource "$out/share/ghostscript/${version}"

    mkdir -p "$doc/share/ghostscript/${version}"
    mv "$out/share/ghostscript/${version}"/{doc,examples} "$doc/share/ghostscript/${version}/"

    ln -s "${fonts}" "$out/share/ghostscript/fonts"
  '';

  # Sometimes throws weird errors for 9.18
  parallelInstall = false;

  passthru = {
    inherit version fonts;

    srcVerification = fetchurl {
      failEarly = true;
      md5Url = "${baseUrl}/MD5SUMS";
      sha1Url = "${baseUrl}/SHA1SUMS";
      sha256Url = "${baseUrl}/SHA256SUMS";
      sha512Url = "${baseUrl}/SHA512SUMS";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.ghostscript.com/";
    description = "PostScript interpreter (mainline version)";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
