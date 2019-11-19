{ stdenv
, fetchFromGitHub
, iucode-tool
}:

let
  date = "2019-11-15";
  rev = "33b7b2f3817e362111cd91910026ab8907f21710";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "intel";
    repo = "Intel-Linux-Processor-Microcode-Data-Files";
    inherit rev;
    sha256 = "696d1adf2d1f4cea6732140290eb646720aadb4539c2b03bed317b5d099a4553";
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
