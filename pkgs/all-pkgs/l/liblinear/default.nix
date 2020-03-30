{ stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  name = "liblinear-2.30";
  
  src = fetchurl {
    url = "https://www.csie.ntu.edu.tw/~cjlin/liblinear/${name}.tar.gz";
    multihash = "QmVzLRKiQVitvtmxMZxnDvyiZweUNfEW5LgAueDRYwgVrN";
    sha256 = "881c7039c6cf93119c781fb56263de91617b3eca8c3951f2c19a3797de95c6ac";
  };

  buildFlags = [
    "lib"
  ];
  
  installPhase = ''
    mkdir -p "$out"/{include,lib}
    cp linear.h "$out"/include
    cp liblinear.so* "$out"/lib
    ln -sv liblinear.so* "$out"/lib/liblinear.so
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
