{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gnum4-${version}";
  version = "1.4.17";

  src = fetchurl {
    url = "mirror://gnu/m4/m4-${version}.tar.bz2";
    sha256 = "0w0da1chh12mczxa5lnwzjk9czi3dq6gnnndbpa6w4rj76b1yklf";
  };

  # We don't want to depend on the bootstraped shell
  configureFlags = [
    "--with-syscmd-shell=/bin/sh"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/m4/;
    description = "GNU M4, a macro processor";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };

}
