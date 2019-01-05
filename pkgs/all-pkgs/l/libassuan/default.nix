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

  version = "2.5.2";
in
stdenv.mkDerivation rec {
  name = "libassuan-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "986b1bf277e375f7a960450fbb8ffbd45294d06598916ad4ebf79aee0cb788e7";
  };

  buildInputs = [
    libgpg-error
    pth
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.5.2";
      outputHash = "986b1bf277e375f7a960450fbb8ffbd45294d06598916ad4ebf79aee0cb788e7";
      inherit (src) outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") urls;
        inherit (gnupg.srcVerification) pgpKeyFingerprints;
      };
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
