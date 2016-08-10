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
  name = "opus-tools-0.1.9";
  src = fetchurl {
    url = "http://downloads.xiph.org/releases/opus/${name}.tar.gz";
    sha256Url = "http://downloads.xiph.org/releases/opus/SHA256SUMS.txt";
    sha256 = "0fk4nknvl111k89j5yckmyrh6b2wvgyhrqfncp7rig3zikbkv1xi";
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
