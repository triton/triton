{ stdenv
, fetchurl
, m4
}:

stdenv.mkDerivation rec {
  name = "gmp-6.1.0";

  src = fetchurl {
    urls = [
      "mirror://gnu/gmp/${name}.tar.bz2"
      "ftp://ftp.gmplib.org/pub/${name}/${name}.tar.bz2"
    ];
    sha256 = "1s3kddydvngqrpc6i1vbz39raya2jdcl042wi0ksbszgjjllk129";
  };

  nativeBuildInputs = [ m4 ];

  configureFlags = [
    "--with-pic"
    "--enable-fat"
    "--enable-cxx"
  ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = "http://gmplib.org/";
    description = "GNU multiple precision arithmetic library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
