set -x
set -e

# Unpack the bootstrap tools tarball.
"$builder" mkdir "$out"
"$builder" unxz <"$tarball" | "$builder" tar x -C "$out"

LD_BINARY="$out"/lib/ld-*so

# Keep a copy of libs so we don't patchelf the running patchelf
LD_LIBRARY_PATH="$out"/lib $LD_BINARY "$out"/bin/cp "$out"/lib/*.so* "$NIX_BUILD_TOP"

# Patch all of the runnable binaries
for i in "$out"/bin/* "$out"/libexec/gcc/*/*/*; do
  if [ -L "$i" ]; then
    continue
  fi
  if [ -z "${i##*/liblto*}" ]; then
    continue
  fi
  if LD_LIBRARY_PATH="$NIX_BUILD_TOP" "$NIX_BUILD_TOP"/ld-*so "$out"/bin/awk \
      '{ exit match($0, /\x7f\x45\x4c\x46/); }' "$i"; then
    continue
  fi
  LD_LIBRARY_PATH="$NIX_BUILD_TOP" "$NIX_BUILD_TOP"/ld-*so "$out"/libexec/patchelf \
    --set-interpreter $LD_BINARY --set-rpath "$out"/lib --force-rpath "$i"
done

# Patch all of the shared objects
for i in "$out"/lib/lib*.so*; do
  if [ -L "$i" ]; then
    continue
  fi
  LD_LIBRARY_PATH="$NIX_BUILD_TOP" "$NIX_BUILD_TOP"/ld-*so "$out"/libexec/patchelf \
    --set-rpath "$out"/lib --force-rpath "$i" || true
done
export PATH=$out/bin

# Remove the patchelf as we no longer need it
rm "$out"/libexec/patchelf

# Fix the libc linker script.
export PATH=$out/bin
for file in "$out"/lib/*; do
  if head -n 1 "$file" | grep -q '^/\*'; then
    sed "s,/nix/store/e*-[^/]*,$out,g" "$file" >"$file.tmp"
    mv "$file.tmp" "$file"
  fi
done

# Create a separate glibc
mkdir -p $glibc
ln -s $out/lib $glibc/lib
ln -s $out/include-glibc $glibc/include
