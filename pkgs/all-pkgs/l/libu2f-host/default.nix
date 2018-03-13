{ stdenv
, fetchurl

, hidapi
, json-c
, openssl
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.5";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    multihash = "QmPLR6juLTQLQGEvNThbyGyzkTv8PSapxLY2gdYTuCjHgL";
    hashOutput = false;
    sha256 = "f32b71435edf6e412f2971edef411f3b4edb419a5356553ad57811ece4a63a95";
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
