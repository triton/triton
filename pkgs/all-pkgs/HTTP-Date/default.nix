{ stdenv
, buildPerlPackage
, fetchurl
}:

buildPerlPackage rec {
  name = "HTTP-Date-6.02";

  src = fetchurl {
    url = "mirror://cpan/authors/id/G/GA/GAAS/${name}.tar.gz";
    sha256 = "e8b9941da0f9f0c9c01068401a5e81341f0e3707d1c754f8e11f42a7e629e333";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
