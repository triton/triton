{ stdenv
, autoconf
, automake
, fetchFromGitHub
, gettext
, libtool
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

  src = fetchFromGitHub {
    version = 3;
    owner = "storaged-project";
    repo = "libbytesize";
    rev = version;
    sha256 = "ad557593e12521d13ea2dbf64ddee906535ddeba8712c0aca3f9dbda06da94de";
  };

  nativeBuildInputs = [
    autoconf
    automake
    gettext
    libtool
    python2
  ];

  buildInputs = [
    glib
    gmp
    mpfr
    pcre
  ];

  preConfigure = ''
    patchShebangs autogen.sh
    ./autogen.sh
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
