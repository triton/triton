{ stdenv
, fetchurl

, libnl
}:

let
  baseUrl = "mirror://kernel/software/network/iw";
in
stdenv.mkDerivation rec {
  name = "iw-4.7";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "d1720c04bc26661d42e71d13746d5c3aeedb6bdf743f7d6b7b056f0abd345ee8";
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
