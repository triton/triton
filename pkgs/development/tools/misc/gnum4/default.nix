{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "gnum4-1.4.17";

  src = fetchurl {
    url = "mirror://gnu/m4/m4-1.4.17.tar.bz2";
    sha256 = "0w0da1chh12mczxa5lnwzjk9czi3dq6gnnndbpa6w4rj76b1yklf";
  };

  doCheck = true;

  configureFlags = "--with-syscmd-shell=${stdenv.shell}";

  # Upstream is aware of it; it may be in the next release.
  patches = [ ./s_isdir.patch ];

  meta = {
    homepage = http://www.gnu.org/software/m4/;
    description = "GNU M4, a macro processor";

    license = stdenv.lib.licenses.gpl3Plus;
  };

}
