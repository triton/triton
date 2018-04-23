{ stdenv
, fetchFromGitHub

, bzip2
, expat
, lmdb
, mcpp
, openssl
}:

# TODO: support for java, mono, python, & ruby
let
  version = "3.7.1";
in
stdenv.mkDerivation rec {
  name = "ice-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "39c3fe53c6e5b1662a7b8286b11a7273e4a5253c1adaa3daba6f18d82cc51ff2";
  };

  buildInputs = [
    bzip2
    expat
    lmdb
    mcpp
    openssl
  ];

  postUnpack = ''
    export srcRoot="$srcRoot/cpp"
  '';

  preConfigure = ''
    makeFlagsArray+=("prefix=$out")
  '';

  makeFlags = [
    # Required to put docs / manpages in $out/share
    "USR_DIR_INSTALL=yes"
  ];

  buildFlags = [
    "srcs"
  ];

  postInstall = ''
    install_slice() {
      local actualMakeFlags
      commonMakeFlags 'install'
      actualMakeFlags+=("-C" ".." "install-slice")
      printMakeFlags 'install-slice'
      make "''${actualMakeFlags[@]}"
    }
    install_slice
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
