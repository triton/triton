{ stdenv
, fetchurl
, lib
}:

stdenv.mkDerivation rec {
  name = "giflib-5.1.8";

  src = fetchurl {
    url = "mirror://sourceforge/giflib/${name}.tar.gz";
    sha256 = "d105a905df34a7822172d13657cdae3d4b0c8e8c7067ccf05e39a40044f8ca53";
  };

  meta = with lib; {
    description = "A library for reading and writing gif images";
    license = licenses.mit;
    maintainers = with stdenv.lib.maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
