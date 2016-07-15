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

  version = "2.4.3";
in
stdenv.mkDerivation rec {
  name = "libassuan-${version}";

  src = fetchurl {
    urls = tarballUrls version;
    allowHashOutput = false;
    sha256 = "22843a3bdb256f59be49842abf24da76700354293a066d82ade8134bb5aa2b71";
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
    srcVerification = fetchurl rec {
      failEarly = true;
      urls = tarballUrls "2.4.3";
      pgpsigUrls = map (n: "${n}.sig") urls;
      inherit (gnupg.srcVerification) pgpKeyFingerprints;
      outputHash = "22843a3bdb256f59be49842abf24da76700354293a066d82ade8134bb5aa2b71";
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
