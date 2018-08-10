{ stdenv
, fetchurl
, iucode-tool
}:

let
  version = "2018-08-07";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "28039";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmQFmb1DQWCTE8oKBYLuksxFvugv8o5LzYZ6T9LLThF1oh";
    hashOutput = false;
    sha256 = "29f9e8dc27e6c9b6488cecd7fe2394030307799e511db2d197d9e6553a7f9e40";
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
      md5Confirm = "49f534f1079d3c5bc178a150c1c105aa";
      inherit (src) urls outputHash outputHashAlgo;
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
