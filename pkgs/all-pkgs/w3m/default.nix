{ stdenv
, fetchTritonPatch
, fetchpatch
, fetchzip
, gettext

, boehmgc
, gpm
, imlib2
, man
, ncurses
, openssl
, perl
, xorg
, zlib
}:

let
  inherit (stdenv.lib)
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "w3m-0.5.3-2015-12-20";

  src = fetchzip {
    url = "http://anonscm.debian.org/cgit/collab-maint/w3m.git/snapshot/e0b6e022810271bd0efcd655006389ee3879e94d.tar.xz";
    sha256 = "1vahm3719hb0m20nc8k88165z35f8b15qasa0whhk78r12bls1q6";
  };

  nativeBuildInputs = [ gettext ];

  buildInputs = [
    boehmgc
    gpm
    ncurses
    openssl
    imlib2
    xorg.libX11
    zlib
  ];

  # we must set these so that the generated files (e.g. w3mhelp.cgi) contain
  # the correct paths.
  PERL = "${perl}/bin/perl";
  MAN = "${man}/bin/man";

  # for w3mimgdisplay
  # see: https://bbs.archlinux.org/viewtopic.php?id=196093
  LIBS = "-lX11";

  patches = [
    (fetchTritonPatch {
      rev = "78526c83438b5935a0d7516e3cbe0e3482495ffe";
      file = "w3m/RAND_egd.libressl.patch";
      sha256 = "bf1e2c20770a40e3ab91bf45d08b9a3b6037a70e9e49e6c8cac54fbcb888607a";
    })
    (fetchpatch {
      name = "https.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/https.patch?h=w3m-mouse&id=5b5f0fbb59f674575e87dd368fed834641c35f03";
      sha256 = "08skvaha1hjyapsh8zw5dgfy433mw2hk7qy9yy9avn8rjqj7kjxk";
    })
  ];

  preConfigure = ''
    substituteInPlace ./configure --replace "/lib /usr/lib /usr/local/lib /usr/ucblib /usr/ccslib /usr/ccs/lib /lib64 /usr/lib64" /no-such-path
    substituteInPlace ./configure --replace /usr /no-such-path
  '';

  configureFlags = [
    "--with-ssl=${openssl}"
    "--with-gc=${boehmgc}"
    "--enable-image=x11,fb"
  ];

  postInstall = ''
    ln -s $out/libexec/w3m/w3mimgdisplay $out/bin
  '';

  meta = with stdenv.lib; {
    homepage = http://w3m.sourceforge.net/;
    description = "A text-mode web browser";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
