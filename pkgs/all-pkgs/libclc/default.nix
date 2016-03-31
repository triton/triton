{ stdenv
, fetchFromGitHub
, python2
, ninja

, llvmPackages
}:

stdenv.mkDerivation {
  name = "libclc-2016-02-09";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "b518692b52a0bbdf9cf0e2167b9629dd9501abcd";
    sha256 = "3ee33d3a2c9989ce383b722760e0bd3e5dd80db56c7d48bb0f3014ac0d24eaac";
  };

  nativeBuildInputs = [
    python2
    ninja
  ];
  buildInputs = [
    llvmPackages.llvm
    llvmPackages.clang
  ];

  postPatch = ''
    sed -i 's,^\(llvm_clang =\).*,\1 "${llvmPackages.clang}/bin/clang",g' configure.py
    patchShebangs .
  '';

  preConfigure = ''
    configureFlagsArray+=("--pkgconfigdir=$out/lib/pkgconfig")
  '';

  configureScript = "./configure.py";

  configureFlags = [
    "-g" "ninja"
    "--with-cxx-compiler=${llvmPackages.clang}/bin/clang++"
  ];

  meta = with stdenv.lib; {
    homepage = http://libclc.llvm.org/;
    description = "Implementation of the library requirements of the OpenCL C programming language";
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
