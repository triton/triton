{ stdenv
, fetchurl
, lib
}:

let
  inherit (lib)
    boolEn;

  version = "0.1.1";
in
stdenv.mkDerivation rec {
  name = "textencode-${version}";

  src = fetchurl {
    url = "https://github.com/triton/textencode/releases/download/v${version}/${name}.tar.xz";
    multihash = "QmP9MUrj2V3B5PuN4qmuDYo2LowMZYJJmLwGpZUnWYaZWq";
    sha256 = "f4584eb7bb725dee1aef745fd53846a8599fc5192f6c2c6e2416e59607b0f12a";
  };

  configureFlags = [
    "--${boolEn doCheck}-tests"
  ];

  doCheck = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
