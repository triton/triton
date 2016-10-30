{ stdenv
, fetchurl

, afflib
#, libewf
, zlib
}:

stdenv.mkDerivation rec {
  name = "sleuthkit-4.3.0";

  src = fetchurl {
    url = "https://github.com/sleuthkit/sleuthkit/releases/download/"
      + "${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "989c69183e4b7bec3734642538802cdcabe346a6dcad31cde45eebcb9bfc191f";
  };

  buildInputs = [
    afflib
    #libewf
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.asc") src.urls;
      pgpKeyFingerprint = "0917 A7EE 58A9 308B 13D3  9633 38AD 602E C745 4C8B";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
