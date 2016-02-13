{ stdenv, fetchurl, ncurses, gettext }:

stdenv.mkDerivation rec {
  name = "nano-${version}";
  version = "2.5.2";

  src = fetchurl {
    url = "mirror://gnu/nano/${name}.tar.gz";
    sha256 = "0hgbmqzjy1pashb1g3qby75pqb7r5g9bmn1iajlx50082b2nmgc9";
  };

  nativeBuildInputs = [ gettext ];
  buildInputs = [ ncurses ];

  configureFlags = [
    "--sysconfdir=/etc"
    "--enable-nls"
    "--disable-tiny"
  ];

  meta = with stdenv.lib; {
    homepage = http://www.nano-editor.org/;
    description = "A small, user-friendly console text editor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ joachifm ];
    platforms = platforms.all;
  };
}
