{ stdenv
, fetchurl

, gdbm
, gmp
, openssl
, readline
, zlib
}:

let
  major = "2.6";
  patch = "3";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "11a83f85c03d3f0fc9b8a9b6cad1b2674f26c5aaa43ba858d4b0fcc2b54171e1";
  };

  buildInputs = [
    gdbm
    gmp
    openssl
    readline
    zlib
  ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "--enable-shared"
  ];

  passthru = {
    gemDir = "lib/ruby/gems/${major}.0";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
