{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "keyutils-1.6";

  src = fetchurl {
    url = "https://people.redhat.com/dhowells/keyutils/${name}.tar.bz2";
    multihash = "QmWHYXov2iaiftkQnXrZwsW1ovTLZHayVnrnx4nxbaQAoK";
    sha256 = "d3aef20cec0005c0fa6b4be40079885567473185b1a57b629b030e67942c7115";
  };

  preBuild = ''
    makeFlagsArray+=(
      "ETCDIR=$out/etc"
      "BINDIR=$out/bin"
      "SBINDIR=$out/bin"
      "SHAREDIR=$out/share/keyutils"
      "MANDIR=$out/share/man"
      "INCLUDEDIR=$out/include"
      "PREFIX=$out"
      "LIBDIR=$out/lib"
      "USRLIBDIR=$out/lib"
    )
  '';

  meta = with stdenv.lib; {
    homepage = http://people.redhat.com/dhowells/keyutils/;
    description = "Tools used to control the Linux kernel key management system";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
