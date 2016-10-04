{ stdenv
, fetchurl

, hidapi
, json-c
}:

stdenv.mkDerivation rec {
  name = "libu2f-host-1.1.3";

  src = fetchurl {
    url = "https://developers.yubico.com/libu2f-host/Releases/${name}.tar.xz";
    hashOutput = false;
    multihash = "QmS21DAPfqHzmimnPEXqpXiBFHf28uQ4Vco2vxpx8CvgRH";
    sha256 = "3e00c1910de64e2c90f20c05bb468b183ffed05e13cb340442d206014752039d";
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
