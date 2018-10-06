{ stdenv
, fetchurl
}:

let
  version = "1.3.0";
in
stdenv.mkDerivation rec {
  name = "exfat-utils-${version}";

  src = fetchurl {
    url = "https://github.com/relan/exfat/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "dfebd07a7b907e2d603d3a9626e6440bd43ec6c4e8c07ccfc57ce9502b724835";
  };

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
