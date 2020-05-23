{ stdenv
, fetchurl

, gdbm
, gmp
, openssl
, readline
, zlib
}:

let
  major = "2.7";
  patch = "1";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "b224f9844646cc92765df8288a46838511c1cec5b550d8874bd4686a904fcee7";
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
