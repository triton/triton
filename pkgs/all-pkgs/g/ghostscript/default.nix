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
, libtiff
, zlib
}:

let
  inherit (stdenv.lib)
    replaceChars;

  version = "9.23";
  versionNoP = replaceChars ["."] [""] version;

  fonts = stdenv.mkDerivation {
    name = "ghostscript-fonts";

    srcs = [
      (fetchurl {
        url = "mirror://sourceforge/gs-fonts/gs-fonts/"
          + "8.11%20(base%2035,%20GPL)/ghostscript-fonts-std-8.11.tar.gz";
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

  baseUrl = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/"
    + "download/gs${versionNoP}";
in
stdenv.mkDerivation rec {
  name = "ghostscript-${version}";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "1fcedc27d4d6081105cdf35606cb3f809523423a6cf9e3c23cead3525d6ae8d9";
  };

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
    libtiff
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "16e1e82d413e33a3a46976f64c275c58a7dc3928";
      file = "ghostscript/urw-font-files.patch";
      sha256 = "1f7e0e309802c4400a31eaadbdd4eb89c63db848f867891119156ce2cffd5c89";
    })
  ];

  postPatch = ''
    rm -r freetype jbig2dec jpeg lcms2art libpng tiff zlib ijs

    grep -q '^INCLUDE=/usr/include' base/unix-aux.mak
    sed -i base/unix-aux.mak \
      -e "s@if ( test -f \$(INCLUDE)[^ ]* )@if ( true )@; s@INCLUDE=/usr/include@INCLUDE=/no-such-path@"

    grep -q '^ZLIBDIR=' configure.ac
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
    "--enable-fontconfig"
    "--enable-freetype"
    "--enable-dynamic"
    "--enable-cups"
    "--with-system-libtiff"
    "--with-drivers=ALL"
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

    ln -s "${fonts}" "$out/share/ghostscript/fonts"
  '';

  # Sometimes throws weird errors for 9.18
  installParallel = false;

  passthru = {
    inherit version fonts;

    srcVerification = fetchurl {
      failEarly = true;
      md5Url = "${baseUrl}/MD5SUMS";
      sha512Url = "${baseUrl}/SHA512SUMS";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "PostScript interpreter";
    homepage = "http://www.ghostscript.com/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
