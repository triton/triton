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

  version = "2.4.4";
in
stdenv.mkDerivation rec {
  name = "libassuan-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    hashOutput = false;
    sha256 = "9e69a102272324de0bb56025779f84fd44901afcc6eac51505f6a63ea5737ca1";
  };

  buildInputs = [
    libgpg-error
    pth
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.4.4";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "9e69a102272324de0bb56025779f84fd44901afcc6eac51505f6a63ea5737ca1";
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
