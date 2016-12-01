{ stdenv
, fetchurl
}:

let
  version = "2.5";
in
stdenv.mkDerivation rec {
  name = "libconfuse-${version}";

  src = fetchurl {
    url = "https://www.intra2net.com/en/developer/libftdi/download/confuse-${version}.tar.gz";
    multihash = "QmVFncTUTxjozp4ARhPgbH7RMH4pyCmWV6nELzSLwmYWGV";
    sha256 = "65451d8d6f5d4ca1dbd0700f3ef2ef257b52b542b3bab4bbeddd539f1c23f859";
  };
  
  configureFlags = [
    "--enable-shared"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
