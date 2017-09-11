{ stdenv
, fetchurl
, lib

, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "glu-9.0.0";

  src = fetchurl {
    url = "ftp://ftp.freedesktop.org/pub/mesa/glu/${name}.tar.bz2";
    multihash = "QmUGFcTRv52ZTMUXfkerNKyyCWVCs8vGn2THFnvvHscvnp";
    sha256 = "1f7ad0d379a722fcbd303aa5650c6d7d5544fde83196b42a73d1193568a4df12";
  };

  buildInputs = [
    mesa_noglu
  ];

  configureFlags = [
    "--disable-debug"
    "--disable-osmesa"
  ];

  meta = with lib; {
    description = "OpenGL utility library";
    homepage = http://cgit.freedesktop.org/mesa/glu/;
    license = licenses.sgi-b-20;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
