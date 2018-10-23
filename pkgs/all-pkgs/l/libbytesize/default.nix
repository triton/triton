{ stdenv
, fetchurl
, gettext
, python3

, glib
, gmp
, mpfr
, pcre
}:

let
  version = "1.4";
in
stdenv.mkDerivation rec {
  name = "libbytesize-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libbytesize/releases/download/${version}/${name}.tar.gz";
    sha256 = "bb4ddc577cf2881834089c2c8d698a73c3f124990937afc2a15d421b2cfd782d";
  };

  nativeBuildInputs = [
    gettext
    python3
  ];

  buildInputs = [
    glib
    gmp
    mpfr
    pcre
  ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
