{ stdenv
, fetchurl
, m4
, perl
}:

stdenv.mkDerivation rec {
  name = "autoconf-2.69";

  src = fetchurl {
    url = "mirror://gnu/autoconf/${name}.tar.xz";
    sha256 = "113nlmidxy9kjr45kg9x3ngar4951mvag1js2a3j8nxcz34wxsv4";
  };

  nativeBuildInputs = [
    m4
    perl
  ];

  meta = with stdenv.lib; {
    homepage = http://www.gnu.org/software/autoconf/;
    description = "Part of the GNU Build System";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
