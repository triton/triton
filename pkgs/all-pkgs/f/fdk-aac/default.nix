{ stdenv
, fetchurl
, lib

# Example encoding program
, exampleSupport ? false
}:

let
  inherit (lib)
    boolEn;
in
stdenv.mkDerivation rec {
  name = "fdk-aac-0.1.4";

  src = fetchurl {
    url = "mirror://sourceforge/opencore-amr/fdk-aac/${name}.tar.gz";
    sha256 = "1aqmzxri23q83wfmwbbashs27mq1mapvfirz5r9i7jkphrwgw42r";
  };

  configureFlags = [
    "--${boolEn exampleSupport}-example"
  ];

  CXXFLAGS = [
    "-std=c++03"
  ];

  meta = with lib; {
    description = "An implementation of the AAC codec from Android";
    homepage = http://sourceforge.net/projects/opencore-amr/;
    license = licenses.asl20;
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
