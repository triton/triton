{ stdenv
, fetchurl
, lib
}:

let
  version = "5.7.2";
in
stdenv.mkDerivation rec {
  name = "unrar-${version}";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/unrarsrc-${version}.tar.gz";
    multihash = "Qmcigu8KLn9CbbXMsQwRCWnGxtFHPPCfYBGU2pnwZvpPHj";
    hashOutput = false;
    sha256 = "46dd410ba57652e972a6c601e7500d01d0ca3257661577466c2cbf6f843cb13a";
  };

  setupHook = ./setup-hook.sh;

  preBuild = ''
    makeFlags+=("DESTDIR=$out")
  '';

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

  meta = with lib; {
    description = "Utility for RAR archives";
    homepage = http://www.rarlab.com/;
    license = licenses.unfreeRedistributable; # unRAR
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
