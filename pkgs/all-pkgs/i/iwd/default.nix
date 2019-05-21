{ stdenv
, fetchurl
, lib

, dbus-dummy
, readline
, systemd-dummy
}:

let
  version = "0.18";

  tarballUrls = [
    "mirror://kernel/linux/network/wireless/iwd-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "iwd-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "2d70cc4889692ec1fb5e2cdbe7469d7d2b35cbecca0d293a78438fbb58e63d3a";
  };

  buildInputs = [
    dbus-dummy
    readline
    systemd-dummy
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sign") tarballUrls;
        pgpDecompress = true;
        pgpKeyFingerprint = "E932 D120 BC2A EC44 4E55  8F01 06CA 9F5D 1DCF 2659";
      };
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
