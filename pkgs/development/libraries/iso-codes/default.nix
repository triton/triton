{ stdenv, fetchurl, gettext, python }:

stdenv.mkDerivation rec {
  name = "iso-codes-3.64";

  src = fetchurl {
    url = "http://pkg-isocodes.alioth.debian.org/downloads/${name}.tar.xz";
    sha256 = "0a87synxkbhvi6r141d31lklrj5vsh2da6nzc1kmgs9p3qw63w2y";
  };

  nativeBuildInputs = [ gettext python ];

  postPatch = ''
    patchShebangs .
  '';

  meta = {
    homepage = http://pkg-isocodes.alioth.debian.org/;
    description = "Various ISO codes packaged as XML files";
    maintainers = [ stdenv.lib.maintainers.urkud ];
    platforms = stdenv.lib.platforms.all;
  };
}
