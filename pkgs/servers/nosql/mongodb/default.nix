{ stdenv, fetchurl, scons, boost, gperftools, pcre, snappy
, zlib, libyamlcpp, sasl, openssl, libpcap, wiredtiger, valgrind
}:

with stdenv.lib;

let version = "3.2.0";
    system-libraries = [
      "pcre"
      "wiredtiger"
      "boost"
      "snappy"
      "valgrind"
      "zlib"
      # "stemmer" -- not nice to package yet (no versioning, no makefile, no shared libs)
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
    ] ++ map (lib: "--use-system-${lib}") system-libraries);

in stdenv.mkDerivation rec {
  name = "mongodb-${version}";

  src = fetchurl {
    url = "http://downloads.mongodb.org/src/mongodb-src-r${version}.tar.gz";
    sha256 = "1vmjb8gbsx7icqvy7k1sfgc3iwd8rnkzgp9ill1byv5qf0b1vpf6";
  };

  nativeBuildInputs = [ scons ];
  inherit buildInputs;

  # Hopefully remove this in 3.2.1+
  patches = [
    (fetchurl {
      name = "mongodb-boost160.patch";
      url = "https://projects.archlinux.org/svntogit/community.git/plain/trunk/boost160.patch?h=packages/mongodb&id=cfa3ad904c66ffbe407d0180fc90c49faef58e59";
      sha256 = "0wvd4hamwrp1067jjjgsyh92spw92z2n32g7a6pkvr838dgs778f";
    })
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

    maintainers = with maintainers; [ bluescreen303 offline wkennington ];
    platforms = platforms.unix;
  };
}
