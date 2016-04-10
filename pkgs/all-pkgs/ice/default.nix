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
  version = "3.6.2";

  src = fetchFromGitHub {
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "778929f0c0a01c1be88d061ea428b43ce2fe8dd50b58815454c98ddbe0df39b2";
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

  preConfigure = ''
    makeFlagsArray+=(
      "prefix=$out"
    )
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
