{ stdenv
, fetchurl

, libmnl
}:

stdenv.mkDerivation rec {
  name = "ipset-6.29";

  src = fetchurl {
    url = "http://ipset.netfilter.org/${name}.tar.bz2";
    md5Confirm = "fd8ea35997115c5c630eee22f0beecec";
    multihash = "Qmc9kMZVZ5MUiXockq3Vu7JpjZ1gmymnUJej2im1pkcLDx";
    sha256 = "6af58b21c8b475b1058e02529ea9f15b4b727dbc13dc9cbddf89941b0103880e";
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
