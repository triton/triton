{ stdenv
, fetchurl
}:
stdenv.mkDerivation rec {
  name = "liblinear-2.20";
  
  src = fetchurl {
    url = "https://www.csie.ntu.edu.tw/~cjlin/liblinear/${name}.tar.gz";
    multihash = "QmZdkESNmLtJHeubDQaf8ymxj6Gp5ZiaywDJrVo5hwme2u";
    sha256 = "3f9fef20e76267bed1b817c9dc96d561ab5ee487828109bd44ed268fbf42048f";
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
