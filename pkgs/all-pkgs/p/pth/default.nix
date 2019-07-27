{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "pth-2.0.7";

  src = fetchurl {
    url = "mirror://gnu/pth/${name}.tar.gz";
    sha256 = "0ckjqw5kz5m30srqi87idj7xhpw6bpki43mj07bazjm2qmh3cdbj";
  };

  # Doesn't play nicely with a POSIX sh
  postPatch = ''
    patchShebangs configure
  '';

  # Fails with -> pth_uctx.c:31:19: fatal error: pth_p.h: No such file or directory
  buildParallel = false;

  # Fails with -> cp: cannot create regular file '/nix/store/h73i6pkzd1md8d90gp9x7wc65kj7hp3f-pth-2.0.7/bin/#INST@10865#': No such file or directory
  installParallel = false;

  meta = with stdenv.lib; {
    description = "The GNU Portable Threads library";
    homepage = http://www.gnu.org/software/pth;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
