{ stdenv
, fetchurl
, iucode-tool
}:

let
  version = "2018-07-03";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "27945";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "QmSe9fWp8KLd2aHwJHtoaM49avvnyYuGQok81cD6VxEb8x";
    hashOutput = false;
    sha256 = "4a1a346fdf48e1626d4c9d0d47bbbc6a4052f56e359c85a3dd2d10fd555e5938";
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
      md5Confirm = "873f2bdd7c0edf317f416f54fee74b42";
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
