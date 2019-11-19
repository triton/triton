{ stdenv
, fetchurl
, lib
}:

let
  version = "2.3.1";
in
stdenv.mkDerivation {
  name = "iucode-tool-${version}";

  src = fetchurl {
    url = "https://gitlab.com/iucode-tool/releases/raw/latest/iucode-tool_${version}.tar.xz";
    multihash = "QmabTpReXnVy9ykWyxF9msPjP6A2Q83bdve1nTBEEEtndK";
    sha256 = "12b88efa4d0d95af08db05a50b3dcb217c0eb2bfc67b483779e33d498ddb2f95";
  };

  postFixup = ''
    rm -rv "$bin"/share
  '';

  outputs = [
    "bin"
    "man"
  ];

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
