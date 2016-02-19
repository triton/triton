{ stdenv, fetchgit, fetchpatch
, ncurses, boehmgc, gettext, zlib
, sslSupport ? true, openssl ? null
, graphicsSupport ? true, imlib2
, x11Support ? graphicsSupport, xorg ? null
, mouseSupport ? true, gpm ? null
, perl, man
}:

assert sslSupport -> openssl != null;
assert graphicsSupport -> imlib2 != null;
assert x11Support -> graphicsSupport && xorg != null;
assert mouseSupport -> gpm != null;

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "w3m-0.5.3-2015-12-20";

  src = fetchgit {
    url = "git://anonscm.debian.org/collab-maint/w3m.git";
    rev = "e0b6e022810271bd0efcd655006389ee3879e94d";
    sha256 = "1vahm3719hb0m20nc8k88165z35f8b15qasa0whhk78r12bls1q6";
  };

  # we must set these so that the generated files (e.g. w3mhelp.cgi) contain
  # the correct paths.
  PERL = "${perl}/bin/perl";
  MAN = "${man}/bin/man";

  patches = [
    ./RAND_egd.libressl.patch
    (fetchpatch {
      name = "https.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/https.patch?h=w3m-mouse&id=5b5f0fbb59f674575e87dd368fed834641c35f03";
      sha256 = "08skvaha1hjyapsh8zw5dgfy433mw2hk7qy9yy9avn8rjqj7kjxk";
    })
  ] ++ optional (graphicsSupport && !x11Support) [ ./no-x11.patch ];

  nativeBuildInputs = [ gettext ];
  buildInputs = [ ncurses boehmgc zlib ]
    ++ optional sslSupport openssl
    ++ optional mouseSupport gpm
    ++ optional graphicsSupport imlib2
    ++ optional x11Support xorg.libX11;

  postInstall = optionalString graphicsSupport ''
    ln -s $out/libexec/w3m/w3mimgdisplay $out/bin
  '';

  configureFlags = "--with-ssl=${openssl} --with-gc=${boehmgc}"
    + optionalString graphicsSupport " --enable-image=${optionalString x11Support "x11,"}fb";

  preConfigure = ''
    substituteInPlace ./configure --replace "/lib /usr/lib /usr/local/lib /usr/ucblib /usr/ccslib /usr/ccs/lib /lib64 /usr/lib64" /no-such-path
    substituteInPlace ./configure --replace /usr /no-such-path
  '';

  # for w3mimgdisplay
  # see: https://bbs.archlinux.org/viewtopic.php?id=196093
  LIBS = optionalString x11Support "-lX11";

  meta = {
    homepage = http://w3m.sourceforge.net/;
    description = "A text-mode web browser";
    maintainers = [ maintainers.mornfall maintainers.cstrahan ];
    platforms = stdenv.lib.platforms.all;
  };
}
