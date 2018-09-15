{ stdenv
, fetchurl
, iucode-tool
}:

let
  version = "2018-08-07a";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "28087";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmaEb3xGPG33EBU2cPog3c5BW1YG39r5S9xxgfKuEAQY5W";
    hashOutput = false;
    sha256 = "46ab18699ec42eb6cc01ee1846ec4d7ca979766dee2156f92d69e2f6df548137";
  };

  nativeBuildInputs = [
    iucode-tool
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  buildPhase = ''
    iucode_tool --write-earlyfw=initrd intel-ucode*/
  '';

  installPhase = ''
    install -D -m755 -v initrd "$out"/'${initrdPath}'
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = {
        md5Confirm = "b12f8680d87c81a302e8c85712ed1a80";
      };
    };
    inherit initrdPath;
  };

  meta = with stdenv.lib; {
    description = "Microcode for Intel processors";
    homepage = http://www.intel.com/;
    license = licenses.unfreeRedistributableFirmware;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
