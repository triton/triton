{ stdenv
, fetchTritonPatch
, fetchurl
, scons

, boost
, cyrus-sasl
, gperftools
, libpcap
, openssl_1-0-2
, pcre
, snappy
, wiredtiger
, yaml-cpp
, zlib
}:

let
  version = "3.4.6";

  inherit (stdenv.lib)
    concatStringsSep;
in
stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "https://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "8170360f6dfede9c19c131f3d76831e952b3f1494925aa7e2a3a2f95b58ad901";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    boost
    cyrus-sasl
    gperftools
    libpcap
    openssl_1-0-2
    pcre
    snappy
    wiredtiger
    yaml-cpp
    zlib
  ];

  patches = [
    # Hopefully remove this in 3.4.7+
    (fetchTritonPatch {
      rev = "2e0d2f49a92924986bacbcf32c1594d834336095";
      file = "m/mongodb/0001-boost-1.60.patch";
      sha256 = "0e9da35f4303e53daf51e78961c517895f2d12f4fa49298f01e1665e15246d73";
    })
    (fetchTritonPatch {
      rev = "2e0d2f49a92924986bacbcf32c1594d834336095";
      file = "m/mongodb/0002-boost-1.62.patch";
      sha256 = "8ad9640407be6f945b38275ff75014c8ba2c6118a25fba63a490c640267b4b66";
    })
    (fetchTritonPatch {
      rev = "2e0d2f49a92924986bacbcf32c1594d834336095";
      file = "m/mongodb/0003-fix-scons-boost.patch";
      sha256 = "200abbd070d5fad9f894375fcd2810008b33985112392f2e00929933347eea0d";
    })
  ];

  # Fix environment variable reading and reduces file size generation by removing debugging symbols
  postPatch = ''
    sed \
      -e '/-ggdb/d' \
      -e 's#env = Environment(#env = Environment(ENV = os.environ,#' \
      -i SConstruct
  '';

  makeFlags = [
    "--release"
    "--ssl"
    "--wiredtiger=on"
    "--js-engine=mozjs"
    "--use-sasl-client"
    "--use-system-pcre"
    "--use-system-wiredtiger"
    "--use-system-boost"
    "--use-system-snappy"
    "--use-system-zlib"
    # "--use-system-valgrind"
    # "--use-system-stemmer"
    "--use-system-yaml"
    # "--use-system-asio"
    # "--use-system-intel_decimal128"
    "--use-system-tcmalloc"
    "--disable-warnings-as-errors"
    "VARIANT_DIR=nixos" # Needed so we don't produce argument lists that are too long for gcc / ld
  ];
  
  buildFlags = [
    "core"
  ];

  preBuild = ''
    makeFlagsArray+=(
      "CCFLAGS=${concatStringsSep " " (map (input: "-I${input}/include") buildInputs)}"
      "LINKFLAGS=${concatStringsSep " " (map (input: "-L${input}/lib") buildInputs)}"
    )
  '';

  preInstall = ''
    installFlagsArray+=("--prefix=$out")
  '';

  meta = with stdenv.lib; {
    description = "a scalable, high-performance, open source NoSQL database";
    homepage = http://www.mongodb.org;
    license = licenses.agpl3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
