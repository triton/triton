{ stdenv
, fetchurl

, readline

, channel
}:

let
  sources = {
    "5.2" = {
      version = "5.2.4";
      multihash = "QmWJdzGBRfifvof4krhv3FRPFxD2FUmz6VcQ83emcoGTML";
      sha256 = "b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b";
    };
    "5.3" = {
      version = "5.3.4";
      multihash = "QmNYqRyfDBStum87ptEAZWBbjAXKC6pmZX9vuJzcdhK5Ru";
      sha256 = "f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c";
    };
  };

  inherit (sources."${channel}")
    version
    multihash
    sha256;
in
stdenv.mkDerivation rec {
  name = "lua-${version}";

  src = fetchurl {
    url = "https://www.lua.org/ftp/${name}.tar.gz";
    inherit
      multihash
      sha256;
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
