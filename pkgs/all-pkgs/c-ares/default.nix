{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "c-ares-1.11.0";

  src = fetchurl {
    url = "http://c-ares.haxx.se/download/${name}.tar.gz";
    sha256 = "1z9y1f835dpi1ka2a2vzjygm3djdvr01036ml4l2js6r2xk2wqdk";
  };

  meta = with stdenv.lib; {
    description = "A C library for asynchronous DNS requests";
    homepage = http://c-ares.haxx.se;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
