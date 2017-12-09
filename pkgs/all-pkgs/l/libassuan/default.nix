{ stdenv
, fetchurl

, gnupg
, libgpg-error
, pth
}:

let
  tarballUrls = version: [
    "mirror://gnupg/libassuan/libassuan-${version}.tar.bz2"
  ];

  version = "2.5.1";
in
stdenv.mkDerivation rec {
  name = "libassuan-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "47f96c37b4f2aac289f0bc1bacfa8bd8b4b209a488d3d15e2229cb6cc9b26449";
  };

  buildInputs = [
    libgpg-error
    pth
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.5.1";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "47f96c37b4f2aac289f0bc1bacfa8bd8b4b209a488d3d15e2229cb6cc9b26449";
      inherit (src) outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "IPC library used by GnuPG and related software";
    homepage = http://gnupg.org;
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
