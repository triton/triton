{ stdenv
, fetchurl

, hidapi
, json-c
, openssl
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.10";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    multihash = "QmVCRA4Sh2xEt7yk5nDD5bjPEVUmuV6PhF4VGRTkDzNamF";
    hashOutput = false;
    sha256 = "4265789ec59555a1f383ea2d75da085f78ee4cf1cd7c44a2b38662de02dd316f";
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
