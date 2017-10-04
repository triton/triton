{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

let
  date = "2017-10-04";
  rev = "ad4ee18ea61a3ab46d425205f91783233516f030";
in
stdenv.mkDerivation {
  name = "libclc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "llvm-mirror";
    repo = "libclc";
    inherit rev;
    sha256 = "9d33560df5a0485395030f66fe1be85d8761d1dc1e2941667d73ed290dbbaa2c";
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
