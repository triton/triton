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
    version = 1;
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "0a78df4ec3b6a04fe23f36e722be5965b54200e5f1042066ddfc5dbecbd5399f";
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
