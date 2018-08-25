{ stdenv
, lib
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "root-nameservers-2018-08-24";

  src = fetchurl {
    name = "${name}.src";
    multihash = "QmRYtiiMYJGUGxSqo2gVN9KbPBNtkRXcRspsTJzLkLgfUQ";
    sha256 = "ead216a387e68703a669f30d3be60aa5453e18d0ae1e11e54080f007715e8652";
  };

  file = "${placeholder "out"}/share/dns/named.root";

  buildCommand = ''
    install -Dm644 "$src" "$file"
  '';

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      url = "https://www.internic.net/domain/named.root";
      fullOpts = {
        pgpsigUrl = "${url}.sig";
        pgpKeyFingerprint = "F0CB 1A32 6BDF 3F3E FA3A  01FA 937B B869 E3A2 38C5";
      };
      sha256 = "e3a76ae953aa11e6598e80b14fd8a93bddd7b3a57830fd9ce16fe820fe1df7a2";
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
