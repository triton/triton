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

  version = "2017-10-20";
in
stdenv.mkDerivation rec {
  name = "zimg-${version}";

  src = fetchFromGitHub {
    version = 3;
    owner = "sekrit-twc";
    repo = "zimg";
    rev = "ae9a2789247d075441191fec469a3a076d314c15";
    sha256 = "0c344bfd876fd0f6b0dd825048f06d07f5fa3fd89323c93d9b7ac0909346b190";
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
