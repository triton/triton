{ stdenv
, fetchurl

, libnl
}:

let
  baseUrl = "mirror://kernel/software/network/iw";
in
stdenv.mkDerivation rec {
  name = "iw-4.9";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "324cc805fad52cba2c16b9ab569906889fb645cc962aac4cfda1db85d2de97ce";
  };

  buildInputs = [
    libnl
  ];

  makeFlags = [
    "PREFIX=\${out}"
  ];

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrl = "${baseUrl}/${name}.tar.sign";
      pgpDecompress = true;
      pgpKeyFingerprint = "C0EB C440 F6DA 091C 884D  8532 E0F3 73F3 7BF9 099A";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with stdenv.lib; {
    description = "Tool to use nl80211";
    homepage = http://wireless.kernel.org/en/users/Documentation/iw;
    license = licenses.isc;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
