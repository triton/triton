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
  version = "23";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "ee4de492c8ba6a646b1cea4e3eb865657d481d9db97de55c4e87fa17ed57ee05";
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
