{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "jemalloc-4.0.4";

  src = fetchurl {
    url = "http://www.canonware.com/download/jemalloc/${name}.tar.bz2";
    sha256 = "1l221xnv6qa9yimwadmx6z7p725j8rfd9v5vpsh1l16dgy6qvniz";
  };

  meta = with stdenv.lib; {
    homepage = http://www.canonware.com/jemalloc/index.html;
    description = "General purpose malloc(3) implementation";
    longDescription = ''
      malloc(3)-compatible memory allocator that emphasizes fragmentation
      avoidance and scalable concurrency support.
    '';
    license = licenses.bsd2;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
