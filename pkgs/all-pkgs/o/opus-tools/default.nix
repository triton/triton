{ stdenv
, fetchurl

, flac
, libogg
, opus
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (stdenv.lib)
    elem
    enFlag
    platforms
    wtFlag;
in

stdenv.mkDerivation rec {
  name = "opus-tools-0.1.10";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
    multihash = "QmeBwLLdV5fnjXKQFpngiBPPJrA3b2g68jLYFJGiCY3JKS";
    hashOutput = false;
    sha256 = "a2357532d19471b70666e0e0ec17d514246d8b3cb2eb168f68bb0f6fd372b28c";
  };

  buildInputs = [
    flac
    libogg
    opus
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-assertions"
    "--disable-oggtest"
    "--disable-opustest"
    (enFlag "sse" (elem targetSystem platforms.x86_64) null)
    "--enable-stack-protector"
    "--enable-pie"
    (wtFlag "flac" (flac != null) null)
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      sha256Url = "https://archive.mozilla.org/pub/opus/SHA256SUMS.txt";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tools to work with opus encoded audio streams";
    homepage = http://www.opus-codec.org/;
    license = licenses.bsd2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
