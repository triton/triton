{ stdenv
, fetchFromGitHub
, python2
, ninja

, clang
, llvm
}:

stdenv.mkDerivation {
  name = "libclc-2016-02-09";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "b518692b52a0bbdf9cf0e2167b9629dd9501abcd";
    sha256 = "d03726e7f3de1c74f201782b0f6754a70810c3593c542eb61320ee350f4fde1a";
  };

  nativeBuildInputs = [
    python2
    ninja
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
    "-g" "ninja"
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
