{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "miniupnpc-2.0";

  src = fetchurl {
    url = "http://miniupnp.free.fr/files/download.php?file=${name}.tar.gz";
    multihash = "Qmf3AjG4KqTBQFxQQE5Nx4zHUrF8uwRsmbQ26uApRKsbaT";
    sha256 = "a1181f15a76f482d34f2a7fe253ecb9cee062cbcc5797c667da56a788fbe4318";
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
