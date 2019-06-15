if [ -z "$llvm_once" ]; then
  # Ensure we don't end up with any references to llvm headers
  export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -ffile-prefix-map=@dev@=/no-such-path/@name@"
  llvm_once=1
fi
