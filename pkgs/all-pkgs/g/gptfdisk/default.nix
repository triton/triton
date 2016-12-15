{ fetchurl
, stdenv

, icu
, ncurses
, popt
, util-linux_lib
}:

let
  version = "1.0.1";
in
stdenv.mkDerivation rec {
  name = "gptfdisk-${version}";

  src = fetchurl {
    # http://www.rodsbooks.com/gdisk/${name}.tar.gz also works, but the home
    # page clearly implies a preference for using SourceForge's bandwidth:
    url = "mirror://sourceforge/gptfdisk/gptfdisk/${version}/${name}.tar.gz";
    sha256 = "1izazbyv5n2d81qdym77i8mg9m870hiydmq4d0s51npx5vp8lk46";
  };

  buildInputs = [
    icu
    ncurses
    popt
    util-linux_lib
  ];

  installPhase = ''
    mkdir -p $out/sbin
    mkdir -p $out/share/man/man8
    for prog in gdisk sgdisk fixparts cgdisk; do
      install -v -m755 $prog $out/sbin
      install -v -m644 $prog.8 $out/share/man/man8
    done
  '';

  meta = with stdenv.lib; {
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
