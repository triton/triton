{ stdenv
, cmake
, fetchurl
, ninja
, python

, libnl
, systemd_lib
}:

let
  version = "14";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    sha256 = "6d2202fcd5aa8f70358d99936944d3e1189a34a08861423cadcba49948fb0370";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python
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
