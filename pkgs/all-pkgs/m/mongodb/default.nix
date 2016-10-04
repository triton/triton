{ stdenv
, fetchurl
, scons

, boost
, cyrus-sasl
, gperftools
, libpcap
, openssl
, pcre
, snappy
, wiredtiger
, yaml-cpp
, zlib
}:

let
  version = "3.2.10";

  inherit (stdenv.lib)
    concatStringsSep;
in
stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "https://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "3bef44f50f302159c26194bcac9d51c81d98d57ea728f55400774850a70f5120";
  };

  nativeBuildInputs = [
    scons
  ];

  buildInputs = [
    boost
    cyrus-sasl
    gperftools
    libpcap
    openssl
    pcre
    snappy
    wiredtiger
    yaml-cpp
    zlib
  ];

  patches = [
    # Hopefully remove this in 3.2.9+
    (fetchurl {
      name = "mongodb-boost160.patch";
      url = "https://projects.archlinux.org/svntogit/community.git/plain/trunk/boost160.patch?h=packages/mongodb&id=cfa3ad904c66ffbe407d0180fc90c49faef58e59";
      sha256 = "0wvd4hamwrp1067jjjgsyh92spw92z2n32g7a6pkvr838dgs778f";
    })

    # When not building with the system valgrind, the build should use the
    # vendored header file - regardless of whether or not we're using the system
    # tcmalloc - so we need to lift the include path manipulation out of the
    # conditional.
    ./valgrind-include.patch
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
