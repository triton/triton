{ stdenv
, buildPerlPackage
, fetchurl
}:

buildPerlPackage rec {
  name = "DBI-1.636";

  src = fetchurl {
    url = "mirror://cpan/authors/id/T/TI/TIMB/${name}.tar.gz";
    sha256 = "8f7ddce97c04b4b7a000e65e5d05f679c964d62c8b02c94c1a7d815bb2dd676c";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
