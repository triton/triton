{ stdenv
, fetchFromGitHub
, iucode-tool
}:

let
  date = "2019-03-12";
  rev = "7febfb94da92a71ca52628b940a8ebbe15bf4e09";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "intel";
    repo = "Intel-Linux-Processor-Microcode-Data-Files";
    inherit rev;
    sha256 = "0986d562df13e701deda00ffb0e3d8de9b0a3502620c65ea785634774bbc7158";
  };

  nativeBuildInputs = [
    iucode-tool
  ];

  buildPhase = ''
    iucode_tool --write-earlyfw=initrd intel-ucode*/
  '';

  installPhase = ''
    install -D -m755 -v initrd "$out"/'${initrdPath}'
  '';

  passthru = {
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
