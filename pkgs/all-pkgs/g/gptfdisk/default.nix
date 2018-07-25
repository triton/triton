{ stdenv
, fetchurl
, lib

, ncurses
, popt
, util-linux_lib
}:

let
  version = "1.0.4";
in
stdenv.mkDerivation rec {
  name = "gptfdisk-${version}";

  src = fetchurl {
    # http://www.rodsbooks.com/gdisk/${name}.tar.gz also works, but the home
    # page clearly implies a preference for using SourceForge's bandwidth:
    url = "mirror://sourceforge/gptfdisk/gptfdisk/${version}/${name}.tar.gz";
    sha256 = "b663391a6876f19a3cd901d862423a16e2b5ceaa2f4a3b9bb681e64b9c7ba78d";
  };

  buildInputs = [
    ncurses
    popt
    util-linux_lib
  ];

  installPhase = ''
    for prog in gdisk sgdisk fixparts cgdisk; do
      install -D -v -m755 $prog $out/bin/$prog
      install -D -v -m644 $prog.8 $out/share/man/man8/$prog.8
    done
  '';

  meta = with lib; {
    description = "Set of text-mode partitioning tools for Globally Unique Identifier (GUID) Partition Table (GPT) disks";
    license = licenses.gpl2;
    homepage = http://www.rodsbooks.com/gdisk/;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
