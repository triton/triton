{ stdenv
, autoconf
, automake
, fetchFromGitHub
, fetchurl
, lib
, libtool

, boost
, openssl
, pythonPackages
, zlib

, channel
}:

let
  inherit (lib)
    boolEn
    optionals
    optionalString
    replaceChars
    splitString
    tail
    versionOlder;

  sources = {
    "1.1" = {
      version = "1.1.7";
      sha256 = "8133bf683308decc24da22aff17437e36c522d8959bcf934e94cf7a3a567f3a9";
    };
    "1.1-head" = {
      fetchzipversion = 5;
      version = "2018-05-01";
      rev = "8808eb7cdd6f3394b76e2b58df3fa37c1841f6d1";
      sha256 = "39095d0de06e01a3fcab7bdc006df3c8e1c6ec84589c88036941a1dc32f8cfa2";
    };
    "head" = {
      fetchzipversion = 2;
      version = "2017-02-18";
      rev = "1ab1b98138e551ee8c8bc0525a51dc31d41999fe";
      sha256 = "aad76aaf1710869a599209f473b93918d11d2b5699b76a6f466d95271ca28aca";
    };
  };

  source = sources."${channel}";

  isHead =
    if channel == "head" then
      true
    else if toString(tail(splitString "-" channel)) == "head" then
      true
    else
      false;

  versionFormatted =
    # For initial minor releases drop the trailing zero
    if replaceChars ["${channel}."] [""] source.version == "0" then
      replaceChars ["."] ["_"] channel
    else
      replaceChars ["."] ["_"] source.version;

  libtorrentOlder = chan: args:
    if versionOlder channel chan then
      args
    else
      null;
in
stdenv.mkDerivation rec {
  name = "libtorrent-rasterbar-${source.version}";

  src =
    if isHead then
      fetchFromGitHub {
        version = source.fetchzipversion;
        owner = "arvidn";
        repo = "libtorrent";
        inherit (source) rev sha256;
      }
    else
      fetchurl {
        url = "https://github.com/arvidn/libtorrent/releases/download/"
          + "libtorrent-${versionFormatted}/${name}.tar.gz";
        inherit (source) sha256;
      };

  nativeBuildInputs = [ ] ++ optionals isHead [
    autoconf
    automake
    libtool
  ];

  buildInputs = [
    boost
    pythonPackages.python
    pythonPackages.wrapPython
    zlib
  ];

  preConfigure = optionalString isHead ''
    ./autotool.sh
  '';

  # FIXME: openssl header not found by qbittorrent
  #        include/libtorrent/hasher.hpp:53:25: fatal error:
  #        openssl/sha.h: No such file or directory
  propagatedBuildInputs = [
    openssl
  ];

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
    (libtorrentOlder "1.1" "--disable-statistics")
    "--disable-disk-stats"
    (libtorrentOlder "1.1" "--disable-geoip")
    "--disable-examples"
    "--disable-tests"
    "--${boolEn (pythonPackages.python != null)}-python-binding"
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    (libtorrentOlder "1.1" "--without-libgeoip")
    "--with-libiconv"
    "--with-openssl=${openssl}"
    "--with-boost-python"
  ];

  meta = with lib; {
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
