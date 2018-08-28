{ stdenv
, fetchurl
, lib

, readline
}:

let
  version = "0.7";

  tarballUrls = [
    "mirror://kernel/linux/network/wireless/iwd-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "iwd-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "eddea0b002014c3f890db46968a54f0b45667975436fd99e4aa14ab9a49fd410";
  };

  buildInputs = [
    readline
  ];

  preConfigure = ''
    configureFlagsArray+=(
      "--with-systemd-unitdir=$out/lib/systemd/system"
      "--with-dbus-busdir=$out/share/dbus-1"
      "--with-dbus-datadir=$out/share"
    )
  '';

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
