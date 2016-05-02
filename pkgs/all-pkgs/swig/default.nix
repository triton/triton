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
      sha256 = "8712255d3ae45c1d7d18c1ae9d9ba8dc1cfb161db5bdcd806e1a4e6624f82fa0";
    };
    "2" = {
      version = "2.0.12";
      sha256 = "5ed085e120674fbe30ca9de79c6395fdb19a2f2ea5f2863620f2496302ee9d40";
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
