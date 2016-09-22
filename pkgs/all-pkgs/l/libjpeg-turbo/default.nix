{ stdenv
, fetchurl
, yasm

, channel ? null
}:

let
  sources = import ./sources.nix;
  source = sources."${channel}";
  version = "${channel}.${source.versionPatch}";
in

stdenv.mkDerivation rec {
  name = "libjpeg-turbo-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${version}/${name}.tar.gz";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    yasm
  ];

  passthru = {
    type = "turbo";
  };

  meta = with stdenv.lib; {
    description = "A faster (using SIMD) libjpeg implementation";
    homepage = http://libjpeg-turbo.virtualgl.org/;
    license = licenses.ijg;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
