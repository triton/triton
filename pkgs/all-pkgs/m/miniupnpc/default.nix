{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "miniupnpc-2.0.20180222";

  src = fetchurl {
    url = [
      "http://miniupnp.tuxfamily.org/files/download.php?file=${name}.tar.gz"
      "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz"
    ];
    name = "${name}.tar.gz";
    multihash = "QmfVvdnyNkBsJSYQ1jjVhokJF2efu77PnFfJAqLcwtemLN";
    sha256 = "587944686469d09f739744b3aed70c7ce753a79c40d6f1227f68a3e962665b75";
  };

  preBuild = ''
    makeFlagsArray+=("INSTALLPREFIX=$out")
  '';

  makeFlags = [
    "OS=Linux"
    "HAVE_IPV6=yes"
  ];

  meta = with lib; {
    description = "UPnP client library and a simple UPnP client";
    homepage = http://miniupnp.free.fr/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
