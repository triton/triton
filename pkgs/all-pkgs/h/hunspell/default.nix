{ stdenv
, fetchurl
, lib

, ncurses
, readline
}:
let
  version = "1.7.0";
in
stdenv.mkDerivation rec {
  name = "hunspell-${version}";

  src = fetchurl {
    # Upstream attached the file in the release notes so urls are non-deterministic.
    # This is the URL if they figure out how to do it correctly.
    url = "https://github.com/hunspell/hunspell/releases/download/v${version}/"
      + "${name}.tar.gz";
    multihash = "QmfXgRXxbkEcWF3mfV3QHNLDA34UWNwDAxBtC9eCeRRPym";
    sha256 = "57be4e03ae9dd62c3471f667a0d81a14513e314d4d92081292b90435944ff951";
  };

  buildInputs = [
    ncurses
    readline
  ];

  configureFlags = [
    "--with-ui"
    "--with-readline"
  ];

  meta = with lib; {
    description = "Spell checker";
    homepage = http://hunspell.sourceforge.net;
    license = licenses.free;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
