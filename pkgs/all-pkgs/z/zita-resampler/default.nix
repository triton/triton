{ stdenv
, fetchurl
, lib
}:

let
  version = "1.6.0";
in
stdenv.mkDerivation rec {
  name = "zita-resampler-${version}";

  src = fetchurl {
    url = "http://kokkinizita.linuxaudio.org/linuxaudio/downloads/${name}.tar.bz2";
    multihash = "QmTgZe1MUMAgHNAhLav71jehHHLKjJ74SC5yjAS4nhQunw";
    sha256 = "10888d76299d8072990939be45d6fc5865f5a45d766d7690819c5899d2a588f0";
  };

  postUnpack = ''
    srcRoot="$srcRoot/libs"
  '';

  postPatch = ''
    sed -i Makefile \
      -e "s@ldconfig@@"
  '';

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  preFixup = /* Fix lib directory name */ ''
    mv -v $out/lib64 $out/lib
  '' + /* Create shared object version symlink for compatibility */ ''
    ln -sv \
      $out/lib/libzita-resampler.so.${version} \
      $out/lib/libzita-resampler.so.1
  '';

  meta = with lib; {
    description = "Library for resampling audio signals";
    homepage = "http://kokkinizita.linuxaudio.org/linuxaudio/zita-resampler/resampler.html";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
