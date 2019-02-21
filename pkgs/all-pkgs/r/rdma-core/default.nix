{ stdenv
, cmake
, fetchurl
, lib
, ninja
, python3

, libnl
, systemd_lib
}:

let
  version = "22.1";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d2ba34326c828ebeff26b300761d3c45ffceb76e0a804e9c612d1baf96ad673a";
  };

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libnl
    systemd_lib
  ];

  passthru = {
    srcVerification = fetchurl rec {
      failEarly = true;
      inherit (src)
        urls
        outputHash
        outputHashAlgo;
      fullOpts = { };
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
