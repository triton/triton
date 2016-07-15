{ stdenv
, buildPerlPackage
, fetchurl
}:

let
  version = "1.1";
in
buildPerlPackage rec {
  name = "SGMLS-${version}";

  src = fetchurl {
    url = "mirror://cpan/authors/id/R/RA/RAAB/SGMLSpm-${version}.tar.gz";
    sha256 = "550c9245291c8df2242f7e88f7921a0f636c7eec92c644418e7d89cfea70b2bd";
  };

  parallelInstall = false;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
