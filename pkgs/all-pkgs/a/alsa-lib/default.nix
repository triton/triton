{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.6";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmQiwxxHKouNYJeRE7tJyqrJ3M1zntxrSJevCNoVxSpwoU";
    sha256 = "5f2cd274b272cae0d0d111e8a9e363f08783329157e8dd68b3de0c096de6d724";
  };

  patches = [
    ./alsa-plugin-conf-multilib.patch
  ];

  meta = with lib; {
    description = "ALSA, the Advanced Linux Sound Architecture libraries";
    homepage = http://www.alsa-project.org/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
