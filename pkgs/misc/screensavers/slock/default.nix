{ stdenv, fetchurl, xorg }:

stdenv.mkDerivation rec {
  name = "slock-1.2";
  src = fetchurl {
    url = "http://dl.suckless.org/tools/${name}.tar.gz";
    sha256 = "1crkyr4vblhciy6vnbjwwjnlkm9yg2hzq16v6hzxm20ai67na0il";
  };
  buildInputs = [ xorg.xproto xorg.libX11 xorg.libXext	];
  installFlags = "DESTDIR=\${out} PREFIX=";
  meta = {
    homepage = http://tools.suckless.org/slock;
    description = "Simple X display locker";
    longDescription = ''
      Simple X display locker. This is the simplest X screen locker.
    '';
    license = "bsd";
    maintainers = with stdenv.lib.maintainers; [ astsmtl ];
    platforms = with stdenv.lib.platforms; linux;
  };
}
