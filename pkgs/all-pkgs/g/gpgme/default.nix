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
  name = "gpgme-1.7.0";

  src = fetchurl {
    url = "mirror://gnupg/gpgme/${name}.tar.bz2";
    hashOutput = false;
    sha256 = "71f55fed0f2b3eaf7a606e59772aa645ce3ffff322d361ce359951b3f755cc48";
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
