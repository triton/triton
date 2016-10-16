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
  version = "3.6.3";

  src = fetchFromGitHub {
    version = 2;
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "da1b4df462dc68f367aa1754c20e08976a56b93d45bed7854666d122d8dd13ee";
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
    makeFlagsArray+=("prefix=$out")
  '';

  parallelBuild = false;

  meta = with stdenv.lib; {
    description = "The internet communications engine";
    homepage = "http://www.zeroc.com/ice.html";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
