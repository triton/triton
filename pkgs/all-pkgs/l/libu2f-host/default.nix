{ stdenv
, fetchurl

, hidapi
, json-c
, openssl
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.9";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    multihash = "QmYesdHh19TznD26Z3C1a3L9nrJ6RBuuYGaadnfdfCgrps";
    hashOutput = false;
    sha256 = "37daef025be55c71998c16d81d2b0bb3f9aa55b736e4e964da0774a6891bd0c2";
  };

  buildInputs = [
    hidapi
    json-c
    openssl
  ];
  
  preConfigure = ''
    configureFlagsArray+=("--with-udevrulesdir=$out/lib/udev/rules.d")
  '';

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--with-openssl"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrls = map (n: "${n}.sig") src.urls;
        pgpKeyFingerprint = "0A3B 0262 BCA1 7053 07D5  FF06 BCA0 0FD4 B216 8C0A";
      };
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
