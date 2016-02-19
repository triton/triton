{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "pth-2.0.7";

  src = fetchurl {
    url = "mirror://gnu/pth/${name}.tar.gz";
    sha256 = "0ckjqw5kz5m30srqi87idj7xhpw6bpki43mj07bazjm2qmh3cdbj";
  };

  #preConfigure = stdenv.lib.optionalString stdenv.isArm ''
  #  configureFlagsArray=("CFLAGS=-DJB_SP=8 -DJB_PC=9")
  #'';

  # Fails with -> pth_uctx.c:31:19: fatal error: pth_p.h: No such file or directory
  parallelBuild = false;

  # Fails with -> cp: cannot create regular file '/nix/store/h73i6pkzd1md8d90gp9x7wc65kj7hp3f-pth-2.0.7/bin/#INST@10865#': No such file or directory
  parallelInstall = false;

  meta = {
    description = "The GNU Portable Threads library";
    homepage = http://www.gnu.org/software/pth;
    platforms = stdenv.lib.platforms.all;
  };
}
