{ stdenv
, bison
, fetchurl
, flex
, lib

, db
, iptables
}:

let
  version = "4.15.0";

  tarballUrls = [
    "mirror://kernel/linux/utils/net/iproute2/iproute2-${version}.tar"
  ];
in
stdenv.mkDerivation rec {
  name = "iproute2-${version}";

  src = fetchurl {
    urls = map (n: "${n}.xz") tarballUrls;
    hashOutput = false;
    sha256 = "48d4616a99d7b609b7b795c0ae8ec57099fb0271ed89253e8772c02327798355";
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
      "PREFIX=$out"
      "SBINDIR=$out/bin"
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

  passthru = {
    srcVerification = fetchurl {
      failEarly = true;
      pgpsigUrls = map (n: "${n}.sign") tarballUrls;
      pgpDecompress = true;
      pgpKeyFingerprint = "9F6F C345 B05B E7E7 66B8  3C8F 80A7 7F60 95CD E47E";
      inherit (src) urls outputHash outputHashAlgo;
    };
  };

  meta = with lib; {
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
