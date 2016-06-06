{ lib, stdenv, fetchurl, pulseaudio_lib, alsa-lib, libcap
}:

stdenv.mkDerivation rec {
  version = "1.2.0";
  name = "libao-${version}";
  src = fetchurl {
    url = "http://downloads.xiph.org/releases/ao/${name}.tar.gz";
    sha256 = "1bwwv1g9lchaq6qmhvj1pp3hnyqr64ydd4j38x94pmprs4d27b83";
  };

  buildInputs =
    [ ] ++
    lib.optional true pulseaudio_lib ++
    lib.optional true libcap;

  meta = {
    homepage = http://xiph.org/ao/;
    license = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ ];
  };
}
