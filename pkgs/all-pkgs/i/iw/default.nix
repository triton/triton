{ stdenv
, fetchurl

, libnl
}:

let
  baseUrl = "mirror://kernel/software/network/iw";
in
stdenv.mkDerivation rec {
  name = "iw-5.0.1";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "1e38ea794a223525b2ea7fe78fd14f2a56121e62e21ba5f9dbe8c494b35b5c0d";
  };

  buildInputs = [
    libnl
  ];

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        pgpsigUrl = "${baseUrl}/${name}.tar.sign";
        pgpDecompress = true;
        pgpKeyFingerprint = "C0EB C440 F6DA 091C 884D  8532 E0F3 73F3 7BF9 099A";
      };
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
