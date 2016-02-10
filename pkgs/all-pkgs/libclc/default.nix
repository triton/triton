{ stdenv
, fetchFromGitHub

, python2
, llvmPackages

# Remove after #24
, ncurses
, zlib
}:

stdenv.mkDerivation {
  name = "libclc-2015-02-09";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "libclc";
    rev = "b518692b52a0bbdf9cf0e2167b9629dd9501abcd";
    sha256 = "0rh2whpi1vmncv9h2rzd6mzvkb1xgfq1glx7hnv805s71v3nfvsp";
  };

  nativeBuildInputs = [
    python2
  ];

  buildInputs = [
    llvmPackages.clang
    llvmPackages.llvm

    # Remove after #24
    ncurses
    zlib
  ];

  postPatch = ''
    patchShebangs configure.py
  '' + ''
    sed -i configure.py \
      -e 's,llvm_clang =.*,llvm_clang = "${llvmPackages.clang}/bin/clang",' \
      -e 's,cxx_compiler =.*,cxx_compiler = "${llvmPackages.clang}/bin/clang++",'
  '';

  configureScript = "./configure.py";

  meta = with stdenv.lib; {
    description = "OpenCL C library";
    homepage = http://libclc.llvm.org/;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
