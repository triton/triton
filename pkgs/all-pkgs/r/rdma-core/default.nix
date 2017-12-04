{ stdenv
, cmake
, fetchurl
, ninja
, python

, libnl
, systemd_lib
}:

let
  version = "15.1";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    sha256 = "927ee00ebb3144e19d5f9c0fa4d1be05616f59309a3e1732a24e215fd818f597";
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
