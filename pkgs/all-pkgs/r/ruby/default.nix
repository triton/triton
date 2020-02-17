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
  patch = "0";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "27d350a52a02b53034ca0794efe518667d558f152656c2baaf08f3d0c8b02343";
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
