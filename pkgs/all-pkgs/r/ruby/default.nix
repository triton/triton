{ stdenv
, fetchurl

, gdbm
, libffi
, openssl
, readline
, zlib
}:

let
  major = "2.4";
  patch = "1";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "4fc8a9992de3e90191de369270ea4b6c1b171b7941743614cc50822ddc1fe654";
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

  preFixup = ''
    rm "$out/share/ri/2.4.0/system/created.rid"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
