{ stdenv
, fetchFromGitHub
, iucode-tool
}:

let
  date = "2019-05-16";
  rev = "1dd14da6d1ea5cfbd95923653f31c04aac3aa655";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "intel";
    repo = "Intel-Linux-Processor-Microcode-Data-Files";
    inherit rev;
    sha256 = "bbfe5497ead058a77a50389b3ccdb1e0e44fd733721ee102d92f966eb7ca2086";
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
