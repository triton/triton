{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

let
  date = "2017-06-02";
  rev = "1cb3fbf504e25d86d972e8b2af3e24571767046b";
in
stdenv.mkDerivation {
  name = "libclc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "llvm-mirror";
    repo = "libclc";
    inherit rev;
    sha256 = "ad68af6b4206533f22eae5d0add7619fc622795e62170954b98e6e98961c59bc";
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
