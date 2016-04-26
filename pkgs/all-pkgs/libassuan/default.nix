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

  version = "2.4.2";
in
stdenv.mkDerivation rec {
  name = "libassuan-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "bb06dc81380b74bf1b64d5849be5c0409a336f3b4c45f20ac688e86d1b5bcb20";
  };

  buildInputs = [
    libgpg-error
    pth
  ];

  # Make sure includes are fixed for callers who don't use libassuan-config
  postInstall = ''
    sed -i 's,#include <gpg-error.h>,#include "${libgpg-error}/include/gpg-error.h",g' $out/include/assuan.h
  '';

  passthru = {
    srcVerified = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.4.2";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerified) pgpKeyIds pgpKeyFingerprints;
      outputHash = "bb06dc81380b74bf1b64d5849be5c0409a336f3b4c45f20ac688e86d1b5bcb20";
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
