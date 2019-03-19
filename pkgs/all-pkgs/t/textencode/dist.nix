{ stdenv
, autoconf-archive
, autoreconfHook
, fetchgit
, lib
, lcov

, googletest
, valgrind
}:

let
  inherit (lib)
    boolEn;

  version = "0.1.2";
in
stdenv.mkDerivation rec {
  name = "textencode-dist-${version}";

  src = fetchgit {
    version = 6;
    url = "git://github.com/triton/textencode";
    rev = "refs/tags/v${version}";
    deepClone = true;  # Faster this way since github is optimized for this
    sha256 = "2bb2f16a77d4523c7f13b40f48df652f9e5b432c24642b85e4cd3db27830920c";
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    src.deterministic-zip
    lcov
  ];

  buildInputs = [
    googletest
    valgrind
  ];

  configureFlags = [
    "--${boolEn doCheck}-code-coverage"
    "--${boolEn doCheck}-tests"
    "--${boolEn doCheck}-valgrind"
  ];

  doCheck = true;

  preInstall = ''
    installFlagsArray+=("DESTDIR=$NIX_BUILD_TOP")
  '';

  postCheck = ''
    make -j $NIX_BUILD_CORES check-valgrind
    sed -i "s,/tmp/\\*,$NIX_STORE/*," Makefile
    make -j $NIX_BUILD_CORES check-code-coverage
  '';

  doDist = true;

  postDist = ''
    make -j $NIX_BUILD_CORES distcheck

    # Save the dist tarball
    mkdir -p tmp
    pushd tmp >/dev/null
    DISTNAME=textencode-${version}
    unpackFile ../"$DISTNAME".tar.xz
    ! grep -r "$NIX_STORE" .
    mkdir -p "$out"/share/textencode
    deterministic-zip-dist "$DISTNAME" >"$out"/share/textencode/"$DISTNAME".tar.xz
    popd >/dev/null

    # Save the code coverage results
    mkdir -p "$out"/share/textencode
    COVNAME=textencode-${version}-coverage
    ! grep -r "$NIX_STORE" "$COVNAME"
    mkdir -p "$out"/share/textencode
    deterministic-zip-dist "$COVNAME" >"$out"/share/textencode/"$COVNAME".tar.xz
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
