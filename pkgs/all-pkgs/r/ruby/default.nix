{ stdenv
, fetchurl

, gdbm
, libffi
, openssl
, readline
, zlib
}:

let
  major = "2.3";
  patch = "1";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.gz";
    hashOutput = false;  # Get the hash from the website
    sha256 = "b87c738cb2032bf4920fef8e3864dc5cf8eae9d89d8d523ce0236945c5797dcd";
  };

  buildInputs = [
    gdbm
    libffi
    openssl
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-shared"
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
