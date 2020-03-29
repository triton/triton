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
  version = "28.0";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "e8ae3a78f9908cdc9139e8f6a155cd0bb43a30d0e54f28a3c7a2df4af51b3f4d";
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

  # Man pages aren't working in 28.0
  postPatch = ''
    rm -rv buildlib/pandoc-prebuilt
    sed -i '\,/man,d' CMakeLists.txt
  '';

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
