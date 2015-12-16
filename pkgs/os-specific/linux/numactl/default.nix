{ stdenv, fetchurl, autoreconfHook }:

stdenv.mkDerivation rec {
  name = "numactl-2.0.11";

  src = fetchurl {
    url = "ftp://oss.sgi.com/www/projects/libnuma/download/${name}.tar.gz";
    sha256 = "0qbqa9gac2vlahrngi553hws2mqgqdwv2lc69a3yx4gq6l90j325";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = with stdenv.lib; {
    description = "Library and tools for non-uniform memory access (NUMA) machines";
    homepage = http://oss.sgi.com/projects/libnuma/;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington ];
  };
}
