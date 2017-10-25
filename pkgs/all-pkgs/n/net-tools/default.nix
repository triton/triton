{ stdenv
, fetchurl
, fetchgit
, gettext
}:

let
  date = "2016-07-10";
  gitRev = "115f1af2494ded1fcd21c8419d5e289bc4df380f";
in

stdenv.mkDerivation rec {
  name = "net-tools-${date}";

  src = fetchurl {
    name = "${name}.tar.xz";
    multihash = "QmSDSsjomFu6VZ5szCWGh9hyYQDFRKzFbQRJ1Deafh1cm7";
    sha256 = "fc8ebe223a7144b6cde07eceac3b7ed7e71b350107002a21162542680ddfee2d";
  };

  nativeBuildInputs = [
    gettext
  ];

  preBuild = ''
    cp ${./config.h} config.h
    cp ${./config.make} config.make
    makeFlagsArray+=(
      "BASEDIR=$out"
      "mandir=/share/man"
    )
  '';

  passthru = {
    srcTarball = stdenv.mkDerivation {
      name = "net-tools-tarball-${date}";

      src = fetchgit {
        version = 1;
        url = "http://git.code.sf.net/p/net-tools/code";
        rev = gitRev;
        sha256 = "1f7myyc490nq29dhs45sm2njxwdnck69pm9ixiwgj44mxdmj3rbm";
      };

      buildPhase = ''
        cd ..
        tar Jcfv ${name}.tar.xz $srcRoot
      '';

      installPhase = ''
        mkdir -pv $out
        cp -v ${name}.tar.xz $out
      '';
    };
  };

  meta = with stdenv.lib; {
    description = "Tools for controlling the network subsystem in Linux";
    homepage = http://net-tools.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
