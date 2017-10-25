{ stdenv
, fetchurl
, libarchive
}:

let
  version = "2017-07-07";
  version' = stdenv.lib.replaceStrings ["-"] [""] version;
  id = "26925";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${version}";

  src = fetchurl {
    url = "https://downloadmirror.intel.com/${id}/eng/microcode-${version'}.tgz";
    multihash = "Qma7iqTTHuFpJhjE6CdhbPfuRD7kdXwENzarnojJG3KFxb";
    hashOutput = false;
    sha256 = "4fd44769bf52a7ac11e90651a307aa6e56ca6e1a814e50d750ba8207973bee93";
  };

  nativeBuildInputs = [
    libarchive
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  buildPhase = ''
    gcc -O2 -Wall -o intel-microcode2ucode ${./intel-microcode2ucode.c}
    ./intel-microcode2ucode microcode.dat
  '';

  installPhase = ''
    install -D -m755 -v 'microcode.bin' 'kernel/x86/microcode/GenuineIntel.bin'
    mkdir -pv $out
    echo 'kernel/x86/microcode/GenuineIntel.bin' | \
      bsdcpio -o -H newc -R 0:0 > "$out/intel-ucode.img"
  '';

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      md5Confirm = "fe4bcb12e4600629a81fb65208c34248";
      inherit (src) urls outputHash outputHashAlgo;
    };
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
