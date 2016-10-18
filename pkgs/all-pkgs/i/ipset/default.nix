{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.30";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    md5Confirm = "41c32e3b884ec714f0aac95e7675f9d1";
    multihash = "QmSzN6EeYqE1eA5m37VbPW1ZjCW9XgmN2Nwvinmdyu7D5g";
    sha256 = "65bfa43fec3d51a6b4012f3d7e4b93a748df9b71b6cd6c53adbec8083e804a31";
  };

  buildInputs = [
    libmnl
  ];

  # The script fails to detect pkg-config correctly
  preConfigure = ''
    export PKG_CONFIG="$(type -P pkg-config)"
  '';

  configureFlags = [
    "--with-kmod=no"
  ];

  meta = with stdenv.lib; {
    homepage = http://ipset.netfilter.org/;
    description = "Administration tool for IP sets";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
