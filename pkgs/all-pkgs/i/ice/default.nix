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
  version = "3.7.0";
in
stdenv.mkDerivation rec {
  name = "ice-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "dc26d72374aa42e02a850f53d896da48ca47e4f6699638862b932fc6579bb80f";
  };

  buildInputs = [
    bzip2
    expat
    lmdb
    mcpp
    openssl
  ];

  postUnpack = ''
    export srcRoot="$sourceRoot/cpp"
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
