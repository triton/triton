{ stdenv
, fetchurl

, hidapi
, json-c
, openssl
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.7";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    multihash = "QmTymz7GYZ9WDigzzNgshRCcckv7DUeG3b9PzxpDzLvoQW";
    hashOutput = false;
    sha256 = "917a259f2977538bc31e13560c830a11e49f54f27908372c774bbbb042d2dcff";
  };

  buildInputs = [
    hidapi
    json-c
    openssl
  ];
  
  # We don't want the old udev rules by default
  postPatch = ''
    grep -q 'udevrulesfile=70-old-u2f.rules' configure
    sed -i 's,udevrulesfile=70-old-u2f.rules,udevrulesfile=70-u2f.rules,g' configure
  '';

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
