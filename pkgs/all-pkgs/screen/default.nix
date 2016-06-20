{ stdenv
, fetchTritonPatch
, fetchurl

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
    (fetchTritonPatch {
      rev = "0df4d797fa1d6e4b1ed757a8fcf79aba83a983bc";
      file = "screen/CVE-2015-6806.patch";
      sha256 = "153b91ef6ba32011149329065e83c446d093f0523d4f17bc5357b31b0b2ec94e";
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
