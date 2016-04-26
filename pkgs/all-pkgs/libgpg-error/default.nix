{ stdenv
, fetchurl

, gnupg
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libgpg-error/libgpg-error-${version}.tar.bz2"
  ];

  version = "1.21";
in
stdenv.mkDerivation rec {
  name = "libgpg-error-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "b7dbdb3cad63a740e9f0c632a1da32d4afdb694ec86c8625c98ea0691713b84d";
  };

  postPatch = ''
    sed '/BUILD_TIMESTAMP=/s/=.*/=1970-01-01T00:01+0000/' -i ./configure
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.21";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerified) pgpKeyIds pgpKeyFingerprints;
      outputHash = "b7dbdb3cad63a740e9f0c632a1da32d4afdb694ec86c8625c98ea0691713b84d";
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

