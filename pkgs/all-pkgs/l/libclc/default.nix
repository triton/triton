{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

stdenv.mkDerivation {
  name = "libclc-2016-11-14";

  src = fetchFromGitHub {
    version = 2;
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "b906699f6876538f6528224b858418e4029e1f26";
    sha256 = "d317e16c84ef679101639ed89f47bbc4748c03e05ee68d2a581d4fdda197e834";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    llvm
  ];

  postPatch = ''
    sed -i 's,^\(llvm_clang =\).*,\1 "${clang}/bin/clang",g' configure.py
    patchShebangs .
  '';

  preConfigure = ''
    configureFlagsArray+=("--pkgconfigdir=$out/lib/pkgconfig")
  '';

  configureScript = "./configure.py";

  configureFlags = [
    "--with-cxx-compiler=${clang}/bin/clang++"
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
