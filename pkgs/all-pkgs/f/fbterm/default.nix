{ stdenv
, fetchurl

, fontconfig
, freetype
, gpm
}:

stdenv.mkDerivation rec {
  name = "fbterm-1.7.0";

  src = fetchurl {
    name = "${name}.tar.gz";
    multihash = "QmPZ5VB2zjK1P18mFQfoUhLgZ1C7stSRnULLzVfZXecwic";
    sha256 = "0pciv5by989vzvjxsv1jsv4bdp4m8j0nfbl29jm5fwi12w4603vj";
  };
  
  buildInputs = [
    fontconfig
    freetype
    gpm
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
