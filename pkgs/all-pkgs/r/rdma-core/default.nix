{ stdenv
, cmake
, fetchurl
, ninja

, libnl
, systemd_lib
}:

let
  version = "13";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    sha256 = "e5230fd7cda610753ad1252b40a28b1e9cf836423a10d8c2525b081527760d97";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    libnl
    systemd_lib
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
