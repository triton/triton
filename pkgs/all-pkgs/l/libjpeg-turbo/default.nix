{ stdenv
, fetchurl
, nasm

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
    hashOutput = false;
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    nasm
  ];

  passthru = {
    type = "turbo";
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "7D62 93CC 6378 786E 1B5C  4968 85C7 044E 033F DE16";
      inherit (src) urls outputHash outputHashAlgo;
    };
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
