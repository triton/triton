{ stdenv
, fetchurl

, hidapi
, json-c
, openssl
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.6";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    multihash = "QmRdCxnrCMhcxepKbTTCHhwyvhNYJNUka6wNAFqVGpY7Y5";
    hashOutput = false;
    sha256 = "4da0bb9e32cab230e63bf65252076f9a4b5e40eb9ec2ddaf9376bcef30e7bda7";
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
      pgpsigUrls = map (n: "${n}.sig") src.urls;
      pgpKeyFingerprint = "0A3B 0262 BCA1 7053 07D5  FF06 BCA0 0FD4 B216 8C0A";
      inherit (src) urls outputHash outputHashAlgo;
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
