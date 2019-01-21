{ stdenv
, fetchurl
, lib

, dbus-dummy
, readline
, systemd-dummy
}:

let
  version = "0.14";

  tarballUrls = [
    "mirror://kernel/linux/network/wireless/iwd-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "iwd-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "c4258b5789a8074a2dfdc33ed5f02415b62ff1ce0b7cba636402883933d6a643";
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
