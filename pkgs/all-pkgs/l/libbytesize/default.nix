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
  version = "1.3";
in
stdenv.mkDerivation rec {
  name = "libbytesize-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libbytesize/releases/download/${version}/${name}.tar.gz";
    sha256 = "d1991726a67ee44e4c9b3deaba5bbacd5392d3364439efce08060abc45edf5d0";
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
