{ stdenv
, autoreconfHook
, fetchFromGitHub
, googletest
, lib
}:

let
  inherit (stdenv)
    targetSystem;
  inherit (lib)
    boolEn
    elem
    optionals
    optionalString
    platforms;

  version = "2018-11-22";
in
stdenv.mkDerivation rec {
  name = "zimg-${version}";

  src = fetchFromGitHub {
    version = 6;
    owner = "sekrit-twc";
    repo = "zimg";
    rev = "721d221d1ff658c94bc27ac882fd0ffc16b21ab8";
    sha256 = "5568eac165dfa2dd9793b9aa758d36f348e69f61a73570f337ead0118329be85";
  };

  nativeBuildInputs = [
    autoreconfHook
  ] ++ optionals doCheck [
    googletest
  ];

  postPatch = /* Remove vendored googletest */ optionalString doCheck ''
    sed -i configure.ac \
      -e '/test\/extra\/googletest\/googletest/d'
    sed -i Makefile.am \
      -e 's,-I.*test/extra/googletest/googletest,${googletest},g' \
      -e '/libgtest.la/d'
  '' + /* Don't use -mtune */ ''
    sed -i configure.ac \
      -e '/-mtune/d'
  '';

  configureFlags = [
    "--disable-testapp"
    "--disable-example"
    "--enable-unit-test"
    "--disable-debug"
    "--${boolEn (elem targetSystem platforms.x86-all)}-simd"  # Currently only x86
  ];

  NIX_LDFLAGS = optionals doCheck [
    # googletest no longer provides libtool files
    "-L${googletest}/lib" "-lgtest"
  ];

  doCheck = true;

  meta = with lib; {
    description = "Scaling, colorspace conversion, and dithering library";
    homepage = https://github.com/sekrit-twc/zimg;
    license = licenses.free;  # DWTFYWTPL v2
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
