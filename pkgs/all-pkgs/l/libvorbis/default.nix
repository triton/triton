{ stdenv
, fetchurl

, libogg
}:

stdenv.mkDerivation rec {
  name = "libvorbis-1.3.5";

  src = fetchurl {
    url = "mirror://xiph/vorbis/${name}.tar.xz";
    multihash = "QmVjo48D12soxLwmiRrUT8Vns1L18nFiTBiYhayunXtpxQ";
    sha256 = "1lg1n3a6r41492r7in0fpvzc7909mc5ir9z0gd3qh2pz4yalmyal";
  };

  buildInputs = [
    libogg
  ];

  meta = with stdenv.lib; {
    homepage = http://xiph.org/vorbis/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
