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
  channels = {
    "3" = {
      version = "3.0.8";
      sha256 = "84e4ffdc989465fad522dd870f7655fd3d6c8ae573ee03ef6144854af5cfdeb6";
    };
    "2" = {
      version = "2.0.12";
      sha256 = "3df731d6233ef7484a1b8597c07b79c9ee5c93f2198dd2a293770828ad07276c";
    };
  };

  inherit (channels."${channel}")
    version
    sha256;
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
    description = "SWIG, an interface compiler that connects C/C++ code to higher-level languages";
    homepage = http://swig.org/;
    # Licensing is a mess: http://www.swig.org/Release/LICENSE .
    license = "BSD-style";
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
