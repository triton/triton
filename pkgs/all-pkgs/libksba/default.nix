{ stdenv
, fetchurl

, gnupg
, libgpg-error
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libksba/libksba-${version}.tar.bz2"
  ];

  version = "1.3.3";
in
stdenv.mkDerivation rec {
  name = "libksba-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "11kp3h9l3b8ikydkcdkwgx45r662zi30m26ra5llyhfh6kz5yzqc";
  };

  buildInputs = [
    libgpg-error
  ];

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "1.3.3";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerified) pgpKeyIds pgpKeyFingerprints;
      outputHash = "0c7f5ffe34d0414f6951d9880a46fcc2985c487f7c36369b9f11ad41131c7786";
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
