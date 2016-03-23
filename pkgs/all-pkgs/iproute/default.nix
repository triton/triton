{ stdenv
, bison
, fetchurl
, flex

, db
, iptables
}:

stdenv.mkDerivation rec {
  name = "iproute-4.5.0";

  src = fetchurl {
    url = "mirror://kernel/linux/utils/net/iproute2/${name}.tar.xz";
    sha256 = "0jj9phsi8m2sbnz7bbh9cf9vckm67hs62ab5srdwnrg4acpjj59z";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    db
    iptables
  ];

  preConfigure = ''
    patchShebangs ./configure
    sed -e '/ARPDDIR/d' -i Makefile
  '';

  preBuild = ''
    makeFlagsArray+=(
      "DESTDIR="
      "LIBDIR=$out/lib"
      "SBINDIR=$out/bin"
      "MANDIR=$out/share/man"
    )
    buildFlagsArray+=(
      "CONFDIR=/etc/iproute"
      "DOCDIR=$out/share/doc/iproute"
    )
    installFlagsArray+=(
      "CONFDIR=$out/etc/iproute"
      "DOCDIR=$TMPDIR"
    )
  '';

  meta = with stdenv.lib; {
    homepage = http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2;
    description = "A collection of utilities for controlling TCP/IP networking and traffic control in Linux";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
