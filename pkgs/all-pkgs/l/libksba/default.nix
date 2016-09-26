{ stdenv
, fetchurl

, gnupg
, libgpg-error
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libksba/libksba-${version}.tar.bz2"
  ];

  version = "1.3.5";
in
stdenv.mkDerivation rec {
  name = "libksba-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "41444fd7a6ff73a79ad9728f985e71c9ba8cd3e5e53358e70d5f066d35c1a340";
  };

  buildInputs = [
    libgpg-error
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.3.5";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "41444fd7a6ff73a79ad9728f985e71c9ba8cd3e5e53358e70d5f066d35c1a340";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gnupg.org;
    description = "CMS and X.509 access library under development";
    license = licenses.lgpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
