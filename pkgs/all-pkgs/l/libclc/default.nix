{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

stdenv.mkDerivation {
  name = "libclc-2017-02-24";

  src = fetchFromGitHub {
    version = 2;
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "17648cd846390e294feafef21c32c7106eac1e24";
    sha256 = "24e41e12cd1133e6aab7edc06ec161b1730bbf600a267944fb0c9d9d3b0a1d0d";
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
