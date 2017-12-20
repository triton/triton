{ stdenv
, fetchurl
}:

stdenv.mkDerivation rec {
  name = "ilmbase-2.2.1";

  src = fetchurl {
    url = "mirror://savannah/openexr/${name}.tar.gz";
    sha256 = "cac206e63be68136ef556c2b555df659f45098c159ce24804e9d5e9e0286609e";
  };

  meta = with stdenv.lib; {
    homepage = http://www.openexr.com/;
    license = licenses.bsd3;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
