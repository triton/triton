{ stdenv
, autoreconfHook
, fetchTritonPatch
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "libomxil-bellagio-${version}";
  version = "0.9.3";

  src = fetchurl {
    url = "mirror://sourceforge/omxil/omxil/Bellagio%20${version}/"
        + "${name}.tar.gz";
    sha256 = "0k6p6h4npn8p1qlgq6z3jbfld6n1bqswzvxzndki937gr0lhfg2r";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  patches = [
    (fetchTritonPatch {
      rev = "71aa2d16752c2723852589a565c7bf0a6bdabab1";
      file = "libomxil-bellagio/fedora-fixes.patch";
      sha256 = "1683126ba747ae2f711cf352b289a26c17c56e92745a0ddbd5f066d66a9bd007";
    })
  ];

  # Parallel building fails without fedora-fixes.patch
  parallelBuild = true;

  meta = with stdenv.lib; {
    description = "Implementation of the OpenMAX Integration Layer";
    homepage = http://sourceforge.net/projects/omxil/;
    license = licenses.lgpl21;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
