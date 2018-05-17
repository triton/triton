{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "peg-0.1.18";

  src = fetchurl {
    url = "http://piumarta.com/software/peg/${name}.tar.gz";
    multihash = "QmWTSFX281X4Ze91Ge5q1rDW7hpibQEmpbiT6nSPQ3v3Do";
    sha256 = "20193bdd673fc7487a38937e297fff08aa73751b633a086ac28c3b34890f9084";
  };

  preBuild = ''
    makeFlagsArray+=("PREFIX=$out")
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
