{ stdenv
, fetchFromGitHub

, bzip2
, db
, expat
, mcpp
, openssl
}:

# TODO: support for java, mono, python, & ruby

stdenv.mkDerivation rec {
  name = "ice-${version}";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "2996782d46aa98a0fa699c3c7b75451de8d9d56dec6f8d94450e9246c690cef4";
  };

  buildInputs = [
    bzip2
    db
    expat
    mcpp
    openssl
  ];

  postUnpack = ''
    export sourceRoot="$sourceRoot/cpp"
  '';

  meta = with stdenv.lib; {
    description = "The internet communications engine";
    homepage = "http://www.zeroc.com/ice.html";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ];
    platforms = with platforms;
      x86_64-linux;
  };
}
