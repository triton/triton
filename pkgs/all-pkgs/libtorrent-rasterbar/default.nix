{ stdenv
, fetchurl

, boost
, openssl
, pythonPackages
, zlib

, channel ? null
}:

let
  inherit (stdenv.lib)
    any
    enFlag
    replaceChars
    versionOlder;
  inherit (builtins.getAttr channel (import ./sources.nix))
    sha256
    version;
in

assert any (n: n == channel) [
  "1.0"
  "1.1"
];

let
  versionFormatted =
    # For initial minor releases drop the trailing zero
    if replaceChars ["${channel}."] [""] version == "0" then
      replaceChars ["."] ["_"] channel
    else
      replaceChars ["."] ["_"] version;
  libtorrentOlder = chan: args:
    if versionOlder channel chan then
      args
    else
      null;
in

stdenv.mkDerivation rec {
  name = "libtorrent-rasterbar-${version}";

  src = fetchurl {
    url = "https://github.com/arvidn/libtorrent/releases/download/"
      + "libtorrent-${versionFormatted}/${name}.tar.gz";
    inherit sha256;
  };

  buildInputs = [
    boost
    openssl
    pythonPackages.python
    pythonPackages.wrapPython
    zlib
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
    (enFlag "python-binding" (pythonPackages.python != null) null)
    "--with-boost=${boost.dev}"
    "--with-boost-libdir=${boost.lib}/lib"
    (libtorrentOlder "1.1" "--without-libgeoip")
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
