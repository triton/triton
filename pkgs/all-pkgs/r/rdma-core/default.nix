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
  version = "22";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "42ab5b34054a083e2efb7e8617a8f7cf1a6af40398d9ef195554544700a1783d";
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
