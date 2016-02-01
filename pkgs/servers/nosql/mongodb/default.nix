{ stdenv, fetchurl, scons, boost, gperftools, pcre, snappy
, zlib, libyamlcpp, sasl, openssl, libpcap, wiredtiger, valgrind
}:

# Note:
# The command line tools are written in Go as part of a different package (mongodb-tools)

with stdenv.lib;

let version = "3.2.1";
    system-libraries = [
      "pcre"
      "wiredtiger"
      "boost"
      "snappy"
      "zlib"
      #"valgrind" -- mongodb only requires valgrind.h, which is vendored in the source.
      #"stemmer"  -- not nice to package yet (no versioning, no makefile, no shared libs).
      "yaml"
      #"asio"
      #"intel_decimal128"
    ] ++ optionals stdenv.isLinux [ "tcmalloc" ];
    buildInputs = [
      boost gperftools pcre snappy valgrind
      zlib libyamlcpp sasl openssl libpcap
    ] ++ optional stdenv.is64bit wiredtiger;

    other-args = concatStringsSep " " ([
      "--ssl"
      "--wiredtiger=${if stdenv.is64bit then "on" else "off"}"
      "--js-engine=mozjs"
      "--use-sasl-client"
      "--disable-warnings-as-errors"
      "VARIANT_DIR=nixos" # Needed so we don't produce argument lists that are too long for gcc / ld
      "CC=$CC"
      "CXX=$CXX"
      "CCFLAGS=\"${concatStringsSep " " (map (input: "-I${input}/include") buildInputs)}\""
      "LINKFLAGS=\"${concatStringsSep " " (map (input: "-L${input}/lib") buildInputs)}\""
    ] ++ map (lib: "--use-system-${lib}") system-libraries);

in stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "http://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "059gskly8maj2c9iy46gccx7a9ya522pl5aaxl5vss5bllxilhsh";
  };

  nativeBuildInputs = [ scons ];
  inherit buildInputs;

  patches = [
    # Hopefully remove this in 3.2.2+
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

  postPatch = ''
    # fix environment variable reading
    substituteInPlace SConstruct \
        --replace "env = Environment(" "env = Environment(ENV = os.environ,"
  '';

  buildPhase = ''
    scons -j $NIX_BUILD_CORES core --release ${other-args}
  '';

  installPhase = ''
    mkdir -p $out/lib
    scons -j $NIX_BUILD_CORES install --release --prefix=$out ${other-args}
  '';

  enableParallelBuilding = true;

  meta = {
    description = "a scalable, high-performance, open source NoSQL database";
    homepage = http://www.mongodb.org;
    license = licenses.agpl3;

    maintainers = with maintainers; [ bluescreen303 offline wkennington cstrahan ];
    platforms = platforms.unix;
  };
}
