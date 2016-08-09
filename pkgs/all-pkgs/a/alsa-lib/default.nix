{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "alsa-lib-1.1.2";

  src = fetchurl {
    url = "mirror://alsa/lib/${name}.tar.bz2";
    multihash = "QmWXuyNFMFN5K59TCZnwtwuvg9XLw5b7fHxiKisw2ywzCs";
    sha256 = "1mk1v2av6ibyydgr6f2mxrwy7clgnf0c68s9y2zvh1ibi7csr3fk";
  };

  patches = [
    ./alsa-plugin-conf-multilib.patch
  ];

  meta = with stdenv.lib; {
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
