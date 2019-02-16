# Unpack the bootstrap tools tarball.
echo Unpacking the bootstrap tools...
$builder mkdir $out
< $tarball $builder unxz | $builder tar x -C $out

# Set the ELF interpreter / RPATH in the bootstrap binaries.
echo Patching the bootstrap tools...

LD_BINARY=$out/lib/ld-*so

# On x86_64, ld-linux-x86-64.so.2 barfs on patchelf'ed programs.  So
# use a copy of patchelf.
LD_LIBRARY_PATH=$out/lib $LD_BINARY $out/bin/cp $out/bin/patchelf $out/lib/*.so* .

for i in $out/bin/* $out/libexec/gcc/*/*/*; do
  if [ -L "$i" ]; then continue; fi
  if [ -z "${i##*/liblto*}" ]; then continue; fi
  echo patching "$i"
  LD_LIBRARY_PATH=. ./ld-*so ./patchelf --set-interpreter $LD_BINARY --set-rpath $out/lib --force-rpath "$i"
done

for i in $out/lib/lib*.so*; do
  if [ -L "$i" ]; then continue; fi
  echo patching "$i"
  LD_LIBRARY_PATH=. ./ld-*so ./patchelf --set-rpath $out/lib --force-rpath "$i" || true
done

# Fix the libc linker script.
export PATH=$out/bin
for file in "$out"/lib/*; do
  if head -n 1 "$file" | grep -q '^/\*'; then
    sed "s,/nix/store/e*-[^/]*,$out,g" "$file" >"$file.tmp"
    mv "$file.tmp" "$file"
  fi
done

# Provide some additional symlinks.
ln -s bash $out/bin/sh
ln -s bzip2 $out/bin/bunzip2

# Provide a gunzip script.
cat > $out/bin/gunzip <<EOF
#!$out/bin/sh
exec $out/bin/gzip -d "\$@"
EOF
chmod +x $out/bin/gunzip

# Provide fgrep/egrep.
echo "#! $out/bin/sh" > $out/bin/egrep
echo "exec $out/bin/grep -E \"\$@\"" >> $out/bin/egrep
echo "#! $out/bin/sh" > $out/bin/fgrep
echo "exec $out/bin/grep -F \"\$@\"" >> $out/bin/fgrep

chmod +x $out/bin/egrep $out/bin/fgrep

# Create a separate glibc
mkdir -p $glibc
ln -s $out/lib $glibc/lib
ln -s $out/include-glibc $glibc/include

# Make sure the cc-wrapper doesn't pick this up automagically
mkdir -p "$glibc"/nix-support
touch "$glibc"/nix-support/cc-wrapper-ignored
