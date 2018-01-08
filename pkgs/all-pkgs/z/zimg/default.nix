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

  version = "2017-12-20";
in
stdenv.mkDerivation rec {
  name = "zimg-${version}";

  src = fetchFromGitHub {
    version = 5;
    owner = "sekrit-twc";
    repo = "zimg";
    rev = "8e87f5a4b88e16ccafb2e7ade8ef454aeac19094";
    sha256 = "4845bbecbd6ba3704b612c4bce0c1d4bfc7ff5acd36691a30fd5463e5f56b9c1";
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
