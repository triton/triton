{ stdenv
, fetchurl
, help2man
, m4
, makeWrapper
, perl
}:

stdenv.mkDerivation rec {
  name = "libtool-2.4.6";
  
  src = fetchurl {
    url = "mirror://gnu/libtool/${name}.tar.gz";
    sha256 = "1qq61k6lp1fp75xs398yzi6wvbx232l7xbyn3p13cnh27mflvgg3";
  };
  
  nativeBuildInputs = [
    help2man
    m4
    makeWrapper
    perl
  ];

  preFixup = ''
    wrapProgram $out/bin/libtoolize \
      --prefix PATH : "${m4}/bin"
  '';

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
