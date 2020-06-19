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
  version = "28.1";
in
stdenv.mkDerivation rec {
  name = "rdma-core-${version}";

  src = fetchurl {
    url = "https://github.com/linux-rdma/rdma-core/releases/download/v${version}/${name}.tar.gz";
    hashOutput = false;
    sha256 = "d9961fd9b0867f17cb6a30a728562f00528b63dd72d1168d838220ab44e5c713";
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
