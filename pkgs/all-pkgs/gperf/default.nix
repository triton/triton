{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "gperf-3.0.4";

  src = fetchurl {
    url = "mirror://gnu/gperf/${name}.tar.gz";
    sha256 = "0gnnm8iqcl52m8iha3sxrzrl9mcyhg7lfrhhqgdn4zj00ji14wbn";
  };

  meta = with stdenv.lib; {
    description = "Perfect hash function generator";
    homepage = http://www.gnu.org/software/gperf/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
