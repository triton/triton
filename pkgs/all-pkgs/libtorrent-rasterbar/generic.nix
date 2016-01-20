{ stdenv
, fetchurl
, automake
, autoconf
, libtool

, boost
, openssl
, zlib
, python2
, libiconv
, geoip

# Inherit generics
, version
, sha256
, ...
}:

with {
  inherit (stdenv.lib)
    enFlag
    replaceChars;
};

let
  formattedVersion = replaceChars ["."] ["_"] version;
in

stdenv.mkDerivation rec {
  name = "libtorrent-rasterbar-${version}";

  src = fetchurl {
    url = "https://github.com/arvidn/libtorrent/archive/libtorrent-${formattedVersion}.tar.gz";
    inherit sha256;
  };

  postPatch =
  /* Disable boost python check */ ''
    sed -i configure.ac \
      -e '/test -z "$BOOST_PYTHON_LIB"/d' \
      -e '/Boost.Python library not found/d' \
      -e '/AX_BOOST_PYTHON/d'
  '';

  configureFlags = [
    "--enable-largefile"
    "--disable-logging"
    "--disable-debug"
    "--enable-dht"
    "--enable-encryption"
    #"--enable-export-all"
    #"--enable-pool-allocators"
    "--disable-invariant-checks"
    "--disable-deprecated-functions"
    "--enable-statistics"
    "--enable-disk-stats"
    (enFlag "geoip" (geoip != null) null)
    "--disable-examples"
    "--disable-tests"
    (enFlag "python-binding" (python2 != null) null)
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    "--with-libgeoip=system"
    "--with-libiconv"
  ];

  preConfigure = "./autotool.sh";

  nativeBuildInputs = [
    automake
    autoconf
    libtool
  ];

  buildInputs = [
    boost
    openssl
    libiconv
    zlib
    python2
    geoip
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "BitTorrent implementation focusing on efficiency and scalability";
    homepage = http://www.rasterbar.com/products/libtorrent/;
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];

  };
}
