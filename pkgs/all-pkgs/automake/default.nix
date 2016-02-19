{ stdenv
, fetchurl
, autoconf
, perl
}:

stdenv.mkDerivation rec {
  name = "automake-1.15";

  src = fetchurl {
    url = "mirror://gnu/automake/${name}.tar.xz";
    sha256 = "0dl6vfi2lzz8alnklwxzfz624b95hb1ipjvd3mk177flmddcf24r";
  };

  nativeBuildInputs = [
    perl
    autoconf
  ];

  setupHook = ./setup-hook.sh;

  meta = with stdenv.lib; {
    branch = "1.15";
    homepage = "http://www.gnu.org/software/automake/";
    description = "GNU standard-compliant makefile generator";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux
      ++ i686-linux;
  };
}
