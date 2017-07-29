{ stdenv
, fetchurl
, lib

, icu
, ncurses
, popt
, util-linux_lib
}:

let
  version = "1.0.3";
in
stdenv.mkDerivation rec {
  name = "gptfdisk-${version}";

  src = fetchurl {
    # http://www.rodsbooks.com/gdisk/${name}.tar.gz also works, but the home
    # page clearly implies a preference for using SourceForge's bandwidth:
    url = "mirror://sourceforge/gptfdisk/gptfdisk/${version}/${name}.tar.gz";
    sha256 = "89fd5aec35c409d610a36cb49c65b442058565ed84042f767bba614b8fc91b5c";
  };

  buildInputs = [
    icu
    ncurses
    popt
    util-linux_lib
  ];

  installPhase = ''
    for prog in gdisk sgdisk fixparts cgdisk; do
      install -D -v -m755 $prog $out/bin
      install -D -v -m644 $prog.8 $out/share/man/man8
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
