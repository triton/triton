{ stdenv
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.23";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "7f0c7f65b98c4048f649bfeebfa4d4c1559707492962504592b985634c939eaa";
  };

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.23";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerified) pgpKeyFingerprints;
      outputHash = "7f0c7f65b98c4048f649bfeebfa4d4c1559707492962504592b985634c939eaa";
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
      i686-linux
      ++ x86_64-linux;
  };
}

