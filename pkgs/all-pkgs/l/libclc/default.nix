{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

let
  date = "2018-03-18";
  rev = "96d10f2e9ec4c87d6b8d91e01d4d061915413f3e";
in
stdenv.mkDerivation {
  name = "libclc-${date}";

  src = fetchFromGitHub {
    version = 6;
    owner = "llvm-mirror";
    repo = "libclc";
    inherit rev;
    sha256 = "d7fd34b08360d8d2aab67119afc77d105737555b4d68ca7931e5def1cbbf8029";
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
