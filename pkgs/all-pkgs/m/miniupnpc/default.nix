{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "miniupnpc-2.0.20180410";

  src = fetchurl {
    url = [
      "http://miniupnp.tuxfamily.org/files/download.php?file=${name}.tar.gz"
      "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz"
    ];
    name = "${name}.tar.gz";
    multihash = "QmdhakP6AEv1LHAPqjgyNpNfPYnpWsZsQ61vQ9G3Evjj1m";
    sha256 = "99b25d0c6ae8554dbdcbf68ede9929c06752537a6987635d866e4f3d8244f446";
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
