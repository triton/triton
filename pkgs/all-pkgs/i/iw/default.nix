{ stdenv
, fetchurl

, libnl
}:

let
  baseUrl = "mirror://kernel/software/network/iw";
in
stdenv.mkDerivation rec {
  name = "iw-5.3";

  src = fetchurl {
    url = "${baseUrl}/${name}.tar.xz";
    hashOutput = false;
    sha256 = "04afe857bc8dea67e461946de30ae1b012954b6965839c5c3fda7d0ed15505d5";
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
