{ stdenv
, fetchurl
}:

let
  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "zita-resampler-${version}";

  src = fetchurl {
    url = "http://kokkinizita.linuxaudio.org/linuxaudio/downloads/${name}.tar.bz2";
    sha256 = "0r9ary5sc3y8vba5pad581ha7mgsrlyai83w7w4x2fmhfy64q0wq";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/libs"
  '';

  postPatch = ''
    sed -i Makefile \
      -e "s@ldconfig@@"
  '';

  preBuild = ''
    makeFlagsArray+=(
      "PREFIX=$out"
    )
  '';

  preFixup = /* Fix lib directory name */ ''
    mv -v $out/lib64 $out/lib
  '' + /* Create shared object version symlink for compatibility */ ''
    ln -sv \
      $out/lib/libzita-resampler.so.${version} \
      $out/lib/libzita-resampler.so.1
  '';

  meta = with stdenv.lib; {
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
