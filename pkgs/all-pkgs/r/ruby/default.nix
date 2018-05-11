{ stdenv
, fetchurl

, gdbm
, libffi
, openssl
, readline
, zlib
}:

let
  major = "2.5";
  patch = "1";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    sha256 = "886ac5eed41e3b5fc699be837b0087a6a5a3d10f464087560d2d21b3e71b754d";
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
    rm "$out/share/ri/2.5.0/system/created.rid"
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
