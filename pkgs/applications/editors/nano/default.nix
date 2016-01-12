{ stdenv, fetchurl, ncurses, gettext }:

stdenv.mkDerivation rec {
  name = "nano-${version}";
  version = "2.5.1";

  src = fetchurl {
    url = "mirror://gnu/nano/${name}.tar.gz";
    sha256 = "1piv8prj6w3rvsrrx41ra8c10b8fzkgjhnm6399lsgqqpw0wlvz0";
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
