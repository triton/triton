{ stdenv
, fetchurl

, boost
, openssl
, pythonPackages
, zlib
}:

let
  inherit (stdenv.lib)
    enFlag
    replaceChars;
in

stdenv.mkDerivation rec {
  name = "libtorrent-rasterbar-${version}";
  versionMajor = "1.1";
  versionMinor = "0";
  version = "${versionMajor}.${versionMinor}";

  src = fetchurl {
    url = "https://github.com/arvidn/libtorrent/releases/download/"
      + "libtorrent-${replaceChars ["."] ["_"] versionMajor}/"
      + "${name}.tar.gz";
    sha256 = "2713df7da4aec5263ac11b6626ea966f368a5a8081103fd8f2f2ed97b5cd731d";
  };

  buildInputs = [
    boost
    openssl
    pythonPackages.python
    pythonPackages.wrapPython
    stdenv.libc
    zlib
  ];

  postUnpack = ''
    # Use cmake instead of autotools
    rm -fv configure
  '';

  configureFlags = [
    "--enable-largefile"
    "--disable-logging"
    "--disable-debug"
    "--enable-dht"
    "--enable-encryption"
    #"--enable-export-all"
    "--enable-pool-allocators"
    "--disable-invariant-checks"
    "--enable-deprecated-functions"
    "--disable-statistics"
    "--disable-disk-stats"
    "--disable-examples"
    "--disable-tests"
    (enFlag "python-binding" (pythonPackages.python != null) null)
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    "--with-libiconv"
    "--with-openssl=${openssl}"
    "--with-boost-python"
  ];

  meta = with stdenv.lib; {
    description = "BitTorrent implementation focused on efficiency & scalability";
    homepage = http://libtorrent.org/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
