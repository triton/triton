{ stdenv
, fetchurl
, lib
, perl

, iproute
, ppp
}:

stdenv.mkDerivation rec {
  name = "pptp-1.8.0";

  src = fetchurl {
    url = "mirror://sourceforge/pptpclient/pptp/${name}/${name}.tar.gz";
    sha256 = "e39c42d933242a8a6dd8600a0fa7f0a5ec8f066d10c4149d8e81a5c68fe4bbda";
  };

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    iproute
    ppp
  ];

  postPatch = ''
    sed -i Makefile \
      -e 's/install -o root/install/'
    sed -i routing.c \
      -e 's,/bin/ip,${iproute}/sbin/ip,'
  '';

  preConfigure = ''
    makeFlagsArray+=(
      BINDIR=$out/bin
      MANDIR=$out/share/man/man8
      PPPDIR=$out/etc/ppp
    )
  '';

  makeFlags = [
    "PPPD=${ppp}/bin/pppd"
  ];

  meta = with lib; {
    description = "PPTP client for Linux";
    homepage = http://pptpclient.sourceforge.net/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
