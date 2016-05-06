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
    sha256 = "d228150a18b25b003269219bcd9699a14ac9ed93241dcd154045cf8ffd9f61b3";
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
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
