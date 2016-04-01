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
  patch = "0";
  version = "${major}.${patch}";
in
stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.gz";
    allowHashOutput = false;  # Get the hash from the website
    sha256 = "ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507";
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
