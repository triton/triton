{ stdenv
, fetchurl

, readline
}:

stdenv.mkDerivation rec {
  name = "lua-5.3.4";

  src = fetchurl {
    url = "https://www.lua.org/ftp/${name}.tar.gz";
    multihash = "QmNYqRyfDBStum87ptEAZWBbjAXKC6pmZX9vuJzcdhK5Ru";
    sha256 = "f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c";
  };

  buildInputs = [
    readline
  ];

  preBuild = ''
    makeFlagsArray+=("INSTALL_TOP=$out")
  '';

  buildFlags = [
    "linux"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
