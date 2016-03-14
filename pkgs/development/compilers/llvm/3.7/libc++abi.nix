{ stdenv, cmake, ninja, fetch, libcxx, libunwind, llvm, version }:

stdenv.mkDerivation {
  name = "libc++abi-${version}";

  src = fetch "libcxxabi" "0ambfcmr2nh88hx000xb7yjm9lsqjjz49w5mlf6dlxzmj3nslzx4";

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ libunwind ];

  postUnpack = ''
    unpackFile ${libcxx.src}
    unpackFile ${llvm.src}
    export NIX_CFLAGS_COMPILE+=" -I$PWD/include"
    cmakeFlagsArray+=("-DLLVM_PATH=$PWD/$(ls -d llvm-*)")
    cmakeFlagsArray+=("-DLIBCXXABI_LIBCXX_INCLUDES=$PWD/$(ls -d libcxx-*)/include")
  '';

  installPhase = ''
    install -d -m 755 $out/include $out/lib
    install -m 644 lib/libc++abi.so.1.0 $out/lib
    install -m 644 ../include/cxxabi.h $out/include
    ln -s libc++abi.so.1.0 $out/lib/libc++abi.so
    ln -s libc++abi.so.1.0 $out/lib/libc++abi.so.1
  '';

  meta = {
    homepage = http://libcxxabi.llvm.org/;
    description = "A new implementation of low level support for a standard C++ library";
    license = "BSD";
    maintainers = with stdenv.lib.maintainers; [ vlstill ];
    platforms = stdenv.lib.platforms.all;
  };
}
