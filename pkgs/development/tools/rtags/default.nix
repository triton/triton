{ stdenv, fetchgit, cmake, llvmPackages, openssl, writeScript, bash }:

let llvm-config-wrapper = writeScript "llvm-config" ''
      #! ${bash}/bin/bash
      if [[ "$1" = "--cxxflags" ]]; then
        echo $(${llvmPackages.llvm}/bin/llvm-config "$@") -isystem ${llvmPackages.clang.cc}/include
      else
        ${llvmPackages.llvm}/bin/llvm-config "$@"
      fi
    '';

in stdenv.mkDerivation rec {
  name = "rtags-${version}";
  rev = "9fed420d20935faf55770765591fc2de02eeee28";
  version = "${stdenv.lib.strings.substring 0 7 rev}";

  buildInputs = [ cmake llvmPackages.llvm openssl llvmPackages.clang ];

  preConfigure = ''
    export LIBCLANG_LLVM_CONFIG_EXECUTABLE=${llvm-config-wrapper}
  '';

  src = fetchgit {
    inherit rev;
    fetchSubmodules = true;
    url = "https://github.com/andersbakken/rtags.git";
    sha256 = "1sb6wfknhvrgirqp65paz7kihv4zgg8g5f7a7i14i10sysalxbif";
  };

  meta = {
    description = "C/C++ client-server indexer based on clang";

    homepage = https://github.com/andersbakken/rtags;

    license = stdenv.lib.licenses.gpl3;
  };
}
