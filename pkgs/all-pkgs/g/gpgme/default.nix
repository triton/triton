{ stdenv
, fetchurl
, swig
, python2
, python3

, glib
, gnupg
, libassuan
, libgpg-error
}:

stdenv.mkDerivation rec {
  name = "gpgme-1.11.1";

  src = fetchurl {
    url = "mirror://gnupg/gpgme/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "2d1b111774d2e3dd26dcd7c251819ce4ef774ec5e566251eb9308fa7542fbd6f";
  };

  nativeBuildInputs = [
    python2
    python3
    swig
  ];

  buildInputs = [
    glib
    libassuan
    libgpg-error
  ];

  # HACK: Disable building tests during the build phase since we don't run them
  postPatch = ''
    find . -name Makefile.in -exec sed -i '/^SUBDIRS =/s, \(tests\|''${tests}\),,' {} \;
  '';

  configureFlags = [
    "--enable-fixed-path=${gnupg}/bin"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "http://www.gnupg.org/related_software/gpgme";
    description = "Library for making GnuPG easier to use";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
