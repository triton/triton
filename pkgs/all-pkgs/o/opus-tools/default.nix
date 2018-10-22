{ stdenv
, fetchurl
, lib

, flac
, libogg
, libopusenc
, opus
, opusfile
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    platforms;
in
stdenv.mkDerivation rec {
  name = "opus-tools-0.2";

  src = fetchurl {
    url = "mirror://xiph/opus/${name}.tar.gz";
    multihash = "QmNq7a5wye4nYGkzj7murvfjGyK6u1Abmar6dxM7xNrnUR";
    hashOutput = false;
    sha256 = "b4e56cb00d3e509acfba9a9b627ffd8273b876b4e2408642259f6da28fa0ff86";
  };

  buildInputs = [
    flac
    libogg
    libopusenc
    opus
    opusfile
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--disable-oggtest"
    "--disable-opustest"
    "--disable-opusfiletest"
    "--disable-libopusenctest"
    "--${boolEn (elem targetSystem platforms.x86_64)}-sse"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        sha256Url = "https://archive.mozilla.org/pub/opus/SHA256SUMS.txt";
      };
    };
  };

  meta = with lib; {
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
