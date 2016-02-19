{ stdenv
, fetchurl
, m4
, perl
, help2man
}:

stdenv.mkDerivation rec {
  name = "libtool-2.4.6";
  
  src = fetchurl {
    url = "mirror://gnu/libtool/${name}.tar.gz";
    sha256 = "1qq61k6lp1fp75xs398yzi6wvbx232l7xbyn3p13cnh27mflvgg3";
  };
  
  nativeBuildInputs = [
    m4
    perl
    help2man
  ];

  meta = with stdenv.lib; {
    description = "Generic library support script";
    homepage = http://www.gnu.org/software/libtool/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
