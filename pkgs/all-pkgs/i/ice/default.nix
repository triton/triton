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
  version = "3.7.2";
in
stdenv.mkDerivation rec {
  name = "ice-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "zeroc-ice";
    repo = "ice";
    rev = "v${version}";
    sha256 = "955f53da7a939d78fa1f0821cf982ba6929495929a0c69f5e70904517a8543fb";
  };

  nativeBuildInputs = [
    mcpp
  ];

  buildInputs = [
    bzip2
    expat
    lmdb
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
