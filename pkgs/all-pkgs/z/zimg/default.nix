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

  version = "2018-01-13";
in
stdenv.mkDerivation rec {
  name = "zimg-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "sekrit-twc";
    repo = "zimg";
    rev = "22dd3be5b2c76b4b6c2c0a67f3e2880a10a3daf3";
    sha256 = "9e1f724b4445f776ff44c5618267f558cae323bf584d83bc23af89748d7ccc80";
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
