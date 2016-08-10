{ stdenv
, autoconf
, automake
, bison
, fetchFromGitHub
, libtool

, pcre

, channel ? "3"
}:

let
  inherit (builtins.getAttr channel (import ./sources.nix))
    sha256
    version;
in

stdenv.mkDerivation rec {
  name = "swig-${version}";
  inherit version;

  src = fetchFromGitHub {
    owner = "swig";
    repo = "swig";
    rev = "rel-${version}";
    inherit sha256;
  };

  nativeBuildInputs = [
    autoconf
    automake
    bison
    libtool
  ];

  buildInputs = [
    pcre
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--with-pcre"
    "--disable-ccache"
  ];

  meta = with stdenv.lib; {
    description = "Interface compiler that connects C/C++ & high-level languages";
    homepage = http://swig.org/;
    # Licensing: http://www.swig.org/Release/LICENSE .
    license = licenses.gpl3;
    maintainers = with maintainers; [
      codyopel
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
