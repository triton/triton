{ stdenv
, fetchurl
, fetchTritonPatch
}:

stdenv.mkDerivation rec {
  name = "expat-2.2.0";

  src = fetchurl {
    url = "mirror://sourceforge/expat/${name}.tar.bz2";
    multihash = "QmXyog231KWB6xwMbPjpv51akeJZj1jHsdkVrWNkMxzVgX";
    sha256 = "d9e50ff2d19b3538bd2127902a89987474e1a4db8e43a66a4d1a712ab9a504ff";
  };

  patchFlags = [
    "-p2"
  ];

  patches = [
    (fetchTritonPatch {
      rev = "7968def6dcf2836760c1015f62b9afdde149217d";
      file = "expat/2016-0718-regression.patch";
      sha256 = "e64ff17753e601f23a6825beeb930aef1bec17b7eec7dce4e8c465b3c0cd66ff";
    })
  ];

  meta = with stdenv.lib; {
    description = "A stream-oriented XML parser library written in C";
    homepage = http://www.libexpat.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
