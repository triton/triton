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
  patch = "2";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "91fcde77eea8e6206d775a48ac58450afe4883af1a42e5b358320beb33a445fa";
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
