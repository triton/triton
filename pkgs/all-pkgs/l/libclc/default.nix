{ stdenv
, fetchFromGitHub
, python2

, clang
, llvm
}:

let
  date = "2017-09-04";
  rev = "58f9eef531c3fe91ff9577fa3a91d01f3931e04d";
in
stdenv.mkDerivation {
  name = "libclc-${date}";

  src = fetchFromGitHub {
    version = 3;
    owner = "llvm-mirror";
    repo = "libclc";
    inherit rev;
    sha256 = "fc6cd3a2206f4121c43917677627c63dc41f05bc948ebe5547741b9277702a04";
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
