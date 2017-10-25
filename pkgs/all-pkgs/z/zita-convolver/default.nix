{ stdenv
, fetchurl

, fftw_single
}:

let
  version = "3.1.0";
in
stdenv.mkDerivation rec {
  name = "zita-convolver-${version}";

  src = fetchurl {
    url = "http://kokkinizita.linuxaudio.org/linuxaudio/downloads/"
      + "${name}.tar.bz2";
    multihash = "QmeSkPd2WerWinCXBseqPykEiXAp6vH3gXFfvjhjsoFTW8";
    sha256 = "bf7e93b582168b78d40666974460ad8142c2fa3c3412e327e4ab960b3fb31993";
  };

  buildInputs = [
    fftw_single
  ];

  postUnpack = ''
    srcRoot="$sourceRoot/libs"
  '';

  postPatch = ''
    sed -i Makefile \
      -e 's/ldconfig//'
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preFixup = /* Fix lib directory name */ ''
    mv -v $out/lib64 $out/lib
  '' + /* Create shared object version symlink for compatibility */ ''
    ln -sv \
      $out/lib/libzita-convolver.so.${version} \
      $out/lib/libzita-convolver.so.3
  '';

  meta = with stdenv.lib; {
    description = "Convolution library by Fons Adriaensen";
    homepage = "http://kokkinizita.linuxaudio.org/linuxaudio/";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
