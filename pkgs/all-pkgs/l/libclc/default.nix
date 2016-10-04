{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

stdenv.mkDerivation {
  name = "libclc-2016-09-21";

  src = fetchFromGitHub {
    version = 2;
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "520743b0b72862a987ead6213dc1a5321a2010f9";
    sha256 = "0d4a526e7ba77ba583557f026e97845b6588495a55acde22c54fa401277bf524";
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
