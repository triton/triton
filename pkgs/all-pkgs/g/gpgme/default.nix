{ stdenv
, fetchurl

, glib
, gnupg
, libassuan
, libgpg-error
}:

stdenv.mkDerivation rec {
  name = "gpgme-1.12.0";

  src = fetchurl {
    url = "mirror://gnupg/gpgme/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "b4dc951c3743a60e2e120a77892e9e864fb936b2e58e7c77e8581f4d050e8cd8";
  };

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
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        inherit (gnupg.srcVerification) pgpKeyFingerprints;
      };
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
