{ stdenv
, buildPerlPackage
, fetchurl
}:

buildPerlPackage rec {
  name = "URI-1.71";

  src = fetchurl {
    url = "mirror://cpan/authors/id/E/ET/ETHER/${name}.tar.gz";
    sha256 = "9c8eca0d7f39e74bbc14706293e653b699238eeb1a7690cc9c136fb8c2644115";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
