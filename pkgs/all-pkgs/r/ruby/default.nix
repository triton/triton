{ stdenv
, fetchurl

, gdbm
, libffi
, openssl_1-0-2
, readline
, zlib
}:

let
  major = "2.3";
  patch = "3";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    hashOutput = false;  # Get the hash from the website
    sha256 = "1a4fa8c2885734ba37b97ffdb4a19b8fba0e8982606db02d936e65bac07419dc";
  };

  buildInputs = [
    gdbm
    libffi
    openssl_1-0-2
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
