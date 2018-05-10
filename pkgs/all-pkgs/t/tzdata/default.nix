{ stdenv
, fetchurl
}:

let
  version = "2018e";
in
stdenv.mkDerivation rec {
  name = "tzdata-${version}";

  srcs = [
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzdata${version}.tar.gz";
      multihash = "QmY44fAUFv66ajQhR7sP4FAQPhKrz82gpfc2si9qeDQoTr";
      sha256 = "6b288e5926841a4cb490909fe822d85c36ae75538ad69baf20da9628b63b692e";
    })
    (fetchurl {
      url = "https://www.iana.org/time-zones/repository/releases/tzcode${version}.tar.gz";
      multihash = "Qmd4ow4q4nNGRfWnUoRzEPxXRQjNFeaMG5j7KG51dLr4Uo";
      sha256 = "ca340cf20e80b699d6e5c49b4ba47361b3aa681f06f38a0c88a8e8308c00ebce";
    })
  ];

  srcRoot = ".";

  preUnpack = ''
    mkdir src
    cd src
  '';

  preBuild = ''
    makeFlagsArray+=(
      "TOPDIR=$out"
      "TZDIR=$out/share/zoneinfo"
      "MANDIR=$TMPDIR/share/man"
      "LIBDIR=$TMPDIR/lib"
      "ETCDIR=$TMPDIR/bin"
    )
  '';

  postInstall = ''
    test -e "$out/share/zoneinfo-posix"
    ln -sv ../zoneinfo-posix "$out"/share/zoneinfo/posix
    test -e "$out/share/zoneinfo-leaps"
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/leaps
    ln -sv ../zoneinfo-leaps "$out"/share/zoneinfo/right
  '';

  meta = with stdenv.lib; {
    homepage = http://www.iana.org/time-zones;
    description = "Database of current and historical time zones";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
