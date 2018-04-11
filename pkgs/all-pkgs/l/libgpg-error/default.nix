{ stdenv
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.29";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "ece926fa5719d17a7ad8da618712cfa2f8a796ab2f2af9d544c5bb093383b1ea";
  };

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.29";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "ece926fa5719d17a7ad8da618712cfa2f8a796ab2f2af9d544c5bb093383b1ea";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = "https://www.gnupg.org/related_software/libgpg-error/index.html";
    description = "A small library that defines common error values for all GnuPG components";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}

