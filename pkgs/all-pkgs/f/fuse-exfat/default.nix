{ stdenv
, fetchurl

, fuse_2
}:

let
  version = "1.2.7";
in
stdenv.mkDerivation rec {
  name = "fuse-exfat-${version}";

  src = fetchurl {
    url = "https://github.com/relan/exfat/releases/download/v${version}/${name}.tar.gz";
    sha256 = "82c3cd328179fd1ab8c5e9f1a10b831c2d67c1cf15a7b9b361fc35d02c63c035";
  };

  buildInputs = [
    fuse_2
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
