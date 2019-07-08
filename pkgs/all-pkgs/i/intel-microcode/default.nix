{ stdenv
, fetchFromGitHub
, iucode-tool
}:

let
  date = "2019-06-18";
  rev = "940d904b7272edd689a5f0eef9dee09c13746748";

  initrdPath = "share/intel-microcode/intel-microcode-initrd.img";
in
stdenv.mkDerivation rec {
  name = "intel-microcode-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "intel";
    repo = "Intel-Linux-Processor-Microcode-Data-Files";
    inherit rev;
    sha256 = "9dd99f85e9c48c01bf40773d2d758935c31103bdcf718e91434218709b3519cc";
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
