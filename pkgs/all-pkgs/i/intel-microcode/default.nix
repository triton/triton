{ stdenv
, fetchurl
, iucode-tool
}:

let
  version = "2018-04-25";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "27776";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmekUp1E7PDsJWHjH8nSft37JLrh17oMGcfXwpMxPq3vwy";
    hashOutput = false;
    sha256 = "f0d2492f4561e2559f6c9471b231cb8262d45762c0e7cccf787be5c189b4e2d6";
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
    rm intel-ucode*/list
    iucode_tool --write-earlyfw=initrd intel-ucode*/
  '';

  installPhase = ''
    install -D -m755 -v initrd "$out"/'${initrdPath}'
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Confirm = "99c80f9229554953a868127cda44e7e3";
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
