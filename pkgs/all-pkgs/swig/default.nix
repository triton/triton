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
      sha256 = "19xn59s5g8pgpvy5dhl06qwx84mxym5kywz5kwzspivqi5i0a3h6";
    };
    "2" = {
      version = "2.0.12";
      sha256 = "0khm9gh5pczfcihr0pbicaicc4v9kjm5ip2alvkhmbb3ga6njkcm";
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
