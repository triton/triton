{ stdenv
, fetchurl

, gnupg
, libgpg-error
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libksba/libksba-${version}.tar.bz2"
  ];

  version = "1.3.4";
in
stdenv.mkDerivation rec {
  name = "libksba-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "f6c2883cebec5608692d8730843d87f237c0964d923bbe7aa89c05f20558ad4f";
  };

  buildInputs = [
    libgpg-error
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.3.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "f6c2883cebec5608692d8730843d87f237c0964d923bbe7aa89c05f20558ad4f";
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
