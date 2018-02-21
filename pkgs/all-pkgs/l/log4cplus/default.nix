{ stdenv
, fetchurl
}:

let
  version = "1.2.1";
in
stdenv.mkDerivation rec {
  name = "log4cplus-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/log4cplus/log4cplus-stable/${version}/${name}.tar.xz";
    sha256 = "09899274d18af7ec845ef2c36a86b446a03f6b0e3b317d96d89447007ebed0fc";
  };

  meta = with stdenv.lib; {
    homepage = "http://log4cplus.sourceforge.net/";
    description = "a port the log4j library from Java to C++";
    license = licenses.asl20;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
