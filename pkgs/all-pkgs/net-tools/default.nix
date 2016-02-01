{ stdenv
#, fetchFromSourceforge
, fetchurl
, unzip

, bluez
}:

stdenv.mkDerivation rec {
  name = "net-tools-2016-01-27";

  /*src = fetchFromSourceforge {
    repo = "net-tools";
    rev = "3f170bff115303e92319791cbd56371e33dcbf6d";
    sha256 = "0sj2mqp74p25ijlbnf8x7xyfb74j09w0vd7ya7i24zadcbzh103r";
  };*/

  src = fetchurl {
    url = "https://dl.dropboxusercontent.com/s/jhfbl23megweaj9/" +
          "net-tools-code-3f170bff115303e92319791cbd56371e33dcbf6d.zip";
    sha256 = "07gl1myln86mnrgk6j0ba2li9bywd2nbz1rhn5vfdwc2645dqnjr";
  };

  nativeBuildInputs = [
    unzip
  ];

  buildInputs = [
    bluez
  ];

  preBuild = ''
    cp ${./config.h} config.h
    makeFlagsArray+=(
      "BASEDIR=$out"
      "mandir=/share/man"
    )
  '';

  meta = with stdenv.lib; {
    description = "Tools for controlling the network subsystem in Linux";
    homepage = http://net-tools.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
