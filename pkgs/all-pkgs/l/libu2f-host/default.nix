{ stdenv
, fetchurl

, hidapi
, json-c
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.2";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmTZLXMWFrvYorMP4tfp3FyBC7ZRYM5be5kQzkYrhqSTbq";
    sha256 = "5bcdfbc5e6f972da5395185b71de2272f9a397f0f0d431860e71545f52f1c56a";
  };

  buildInputs = [
    hidapi
    json-c
  ];
  
  # We don't want the old udev rules by default
  postPatch = ''
    sed -i 's,udevrulesfile=70-old-u2f.rules,udevrulesfile=70-u2f.rules,g' configure
  '';

  preConfigure = ''
    configureFlagsArray+=("--with-udevrulesdir=$out/lib/udev/rules.d")
  '';

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
