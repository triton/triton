{ stdenv
, fetchurl
, lib

, ncurses
, popt
, util-linux_lib
}:

let
  version = "1.0.5";
in
stdenv.mkDerivation rec {
  name = "gptfdisk-${version}";

  src = fetchurl {
    # http://www.rodsbooks.com/gdisk/${name}.tar.gz also works, but the home
    # page clearly implies a preference for using SourceForge's bandwidth:
    url = "mirror://sourceforge/gptfdisk/gptfdisk/${version}/${name}.tar.gz";
    sha256 = "0e7d3987cd0488ecaf4b48761bc97f40b1dc089e5ff53c4b37abe30bc67dcb2f";
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
