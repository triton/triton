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
  patch = "0";
  version = "${major}.${patch}";
in

stdenv.mkDerivation rec {
  name = "ruby-${version}";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/${major}/${name}.tar.xz";
    hashOutput = false;  # Get the hash from the website
    sha256 = "3a87fef45cba48b9322236be60c455c13fd4220184ce7287600361319bb63690";
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
