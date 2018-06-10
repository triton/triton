{ stdenv
, fetchurl
, pythonPackages

, boost
, cyrus-sasl
, gperftools
, icu
, libpcap
, mongo-c-driver
, openssl
, pcre
, snappy
, wiredtiger
, yaml-cpp
, zlib
}:

let
  version = "3.6.5";

  inherit (stdenv.lib)
    concatMap
    concatStringsSep
    flip;
in
stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "https://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "b99535800925b5c5a9a103fdad37559b6cde13e7cdce72310f32ff105ec615df";
  };

  nativeBuildInputs = [
    pythonPackages.cheetah
    pythonPackages.pyyaml
    pythonPackages.regex
    pythonPackages.scons
    pythonPackages.typing
  ];

  buildInputs = [
    boost
    cyrus-sasl
    gperftools
    #icu
    libpcap
    mongo-c-driver
    openssl
    pcre
    snappy
    wiredtiger
    yaml-cpp
    zlib
  ];

  # Fix environment variable reading and reduces file size generation by removing debugging symbols
  postPatch = ''
    grep -q '\-ggdb' SConstruct
    grep -q 'env = Environment(' SConstruct
    sed \
      -e '/-ggdb/d' \
      -e 's#env = Environment(#env = Environment(ENV = os.environ,#' \
      -i SConstruct
  '';

  NIX_LDFLAGS = flip concatMap buildInputs (n: [
    "-rpath" "${n.lib or n}/lib"
  ]);

  preConfigure = ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $(cat $NIX_CC/nix-support/orig-cc)/lib"
  '';

  makeFlags = [
    "--release"
    "--ssl"
    "--wiredtiger=on"
    "--js-engine=mozjs"
    "--use-sasl-client"
    "--use-system-tcmalloc"
    "--use-system-pcre"
    "--use-system-wiredtiger"
    "--use-system-boost"
    "--use-system-snappy"
    # "--use-system-valgrind"
    "--use-system-zlib"
    # "--use-system-stemmer"
    "--use-system-yaml"
    # "--use-system-asio"
    # "--use-system-icu"
    # "--use-system-intel_decimal128"
    "--disable-warnings-as-errors"
    "VARIANT_DIR=triton" # Needed so we don't produce argument lists that are too long for gcc / ld
  ];

  buildFlags = [
    "core"
  ];

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
