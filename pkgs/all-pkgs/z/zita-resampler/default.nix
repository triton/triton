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
    multihash = "Qmb3z4bagfp3h9zuwh1GvgRdJNrEngVZS9BvxcR4cnDv6e";
    sha256 = "98034c8c77b03ad1093f7ca0a83ccdfad5a36040a5a95bd4dac80fa68bcf2a65";
  };

  postUnpack = ''
    srcRoot="$sourceRoot/libs"
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
