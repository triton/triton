{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "gengetopt-2.22.6";

  src = fetchurl {
    url = "mirror://gnu/gengetopt/${name}.tar.gz";
    hashOutput = false;
    sha256 = "30b05a88604d71ef2a42a2ef26cd26df242b41f5b011ad03083143a31d9b01f7";
  };

  # Broken in 2.22.6
  buildParallel = false;
  installParallel = false;

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
