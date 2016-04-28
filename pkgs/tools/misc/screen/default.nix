{ stdenv
, fetchurl
, fetchpatch

, ncurses
, pam
}:

stdenv.mkDerivation rec {
  name = "screen-4.3.1";

  src = fetchurl {
    url = "mirror://gnu/screen/${name}.tar.gz";
    sha256 = "0qwxd4axkgvxjigz9xs0kcv6qpfkrzr2gm43w9idx0z2mvw4jh7s";
  };

  buildInputs = [
    ncurses
    pam
  ];

  # TODO: remove when updating the version of screen. Only patches for 4.3.1
  patches = [
    (fetchpatch {
      name = "CVE-2015-6806.patch";
      stripLen = 1;
      url = "http://git.savannah.gnu.org/cgit/screen.git/patch/?id=b7484c224738247b510ed0d268cd577076958f1b";
      sha256 = "160zhpzi80qkvwib78jdvx4jcm2c2h59q5ap7hgnbz4xbkb3k37l";
    })
  ];

  postPatch = ''
    find . -name Makefile.in | xargs sed -i \
      -e "s|/usr/local|/non-existent|g" \
      -e "s|/usr|/non-existent|g"
  '';

  preConfigure = ''
    configureFlagsArray+=(
      "--infodir=$out/share/info"
      "--mandir=$out/share/man"
    )
  '';

  configureFlags = [
    "--enable-telnet"
    "--enable-pam"
    "--with-sys-screenrc=/etc/screenrc"
    "--enable-colors256"
  ];

  doCheck = true;

  # Some generated headers are not ready when needed
  parallelBuild = false;

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/screen/;
    description = "A window manager that multiplexes a physical terminal";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
