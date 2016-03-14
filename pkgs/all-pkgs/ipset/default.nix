{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.28";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    sha256 = "0bkbk47b0c6jha149zkmpmzg2d9dpk3zvs5lz4qyr39z1dckjhpx";
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
