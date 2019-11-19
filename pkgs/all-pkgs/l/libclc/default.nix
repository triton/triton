{ stdenv
, fetchFromGitHub
, python3

, cc_clang
, llvm
}:

let
  date = "2019-03-27";
  rev = "dabae5a2afb78cba0320a86e3f5f0b5dc83e077c";
in
(stdenv.override { cc = cc_clang; }).mkDerivation {
  name = "libclc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "llvm-mirror";
    repo = "libclc";
    inherit rev;
    sha256 = "0da630be50772c51b56f407e432af17301cbe281d2cf9ad5e0fc8891c7142c60";
  };

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    llvm
  ];

  NIX_DEBUG = true;
  NIX_CFLAGS_COMPILE = " -v";

  postPatch = ''
    sed -i 's,^\(llvm_clang =\).*,\1 "${cc_clang}/bin/clang",g' configure.py
    patchShebangs .
  '';

  preConfigure = ''
    configureFlagsArray+=("--pkgconfigdir=$out/lib/pkgconfig")
  '';

  configureScript = "./configure.py";

  configureFlags = [
    "--with-cxx-compiler=${cc_clang}/bin/clang++"
  ];

  meta = with stdenv.lib; {
    homepage = http://libclc.llvm.org/;
    description = "Implementation of the library requirements of the OpenCL C programming language";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
