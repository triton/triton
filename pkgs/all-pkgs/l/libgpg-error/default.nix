{ stdenv
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.34";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "0680799dee71b86b2f435efb825391eb040ce2704b057f6bd3dcc47fbc398c81";
  };

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.34";
      outputHash = "0680799dee71b86b2f435efb825391eb040ce2704b057f6bd3dcc47fbc398c81";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        inherit (gnupg.srcVerification) pgpKeyFingerprints;
      };
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

