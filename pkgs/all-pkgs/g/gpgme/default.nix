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
  name = "gpgme-1.10.0";

  src = fetchurl {
    url = "mirror://gnupg/gpgme/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "1a8fed1197c3b99c35f403066bb344a26224d292afc048cfdfc4ccd5690a0693";
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
