{ stdenv
, buildPerlPackage
, fetchurl
}:

buildPerlPackage rec {
  name = "Encode-Locale-1.05";

  src = fetchurl {
    url = "mirror://cpan/authors/id/G/GA/GAAS/${name}.tar.gz";
    sha256 = "176fa02771f542a4efb1dbc2a4c928e8f4391bf4078473bd6040d8f11adb0ec1";
  };

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
