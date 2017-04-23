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
  version = "0.10";
in
stdenv.mkDerivation rec {
  name = "libbytesize-${version}";

  src = fetchFromGitHub {
    version = 2;
    owner = "rhinstaller";
    repo = "libbytesize";
    rev = version;
    sha256 = "cd4c2780e80dbe8d9bb911ceafd65707ec80c9f07e6a8e37e98407b8ba0cf79e";
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
