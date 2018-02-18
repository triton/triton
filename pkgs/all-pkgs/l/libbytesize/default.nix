{ stdenv
, fetchurl
, gettext
, python2

, glib
, gmp
, mpfr
, pcre
}:

let
  version = "1.2";
in
stdenv.mkDerivation rec {
  name = "libbytesize-${version}";

  src = fetchurl {
    url = "https://github.com/storaged-project/libbytesize/releases/download/${version}/${name}.tar.gz";
    sha256 = "65656ed62080d73d0f21d9647cee20533377bee150e91807fd54c502f3e1108f";
  };

  nativeBuildInputs = [
    gettext
    python2
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
