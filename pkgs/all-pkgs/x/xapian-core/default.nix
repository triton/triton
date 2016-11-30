{ stdenv
, fetchurl

, util-linux_lib
, zlib
}:

let
  version = "1.4.1";
in
stdenv.mkDerivation rec {
  name = "xapian-core-1.4.1";

  src = fetchurl {
    url = "https://oligarchy.co.uk/xapian/${version}/${name}.tar.xz";
    multihash = "QmSWk9ib9puuAUWGzfueYBQCWw2RapsykAQh32N9AkKjHz";
    sha256 = "c5f2534de73c067ac19eed6d6bec65b7b2c1be00131c8867da9e1dfa8bce70eb";
  };

  buildInputs = [
    util-linux_lib
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms; 
      x86_64-linux;
  };
}
