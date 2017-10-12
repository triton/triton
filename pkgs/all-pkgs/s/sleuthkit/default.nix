{ stdenv
, fetchurl

, afflib
#, libewf
, zlib
}:

stdenv.mkDerivation rec {
  name = "sleuthkit-4.4.2";

  src = fetchurl {
    url = "https://github.com/sleuthkit/sleuthkit/releases/download/"
      + "${name}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "135964463f4b0a58fcd95fdf731881fcd6f2f227eeb8ffac004880c8e4d8dd53";
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
