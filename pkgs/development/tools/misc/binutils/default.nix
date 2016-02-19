{ stdenv, fetchurl, fetchTritonPatch, noSysDirs, zlib
, cross ? null, gold ? true, bison ? null
}:

let basename = "binutils-2.23.1"; in

with { inherit (stdenv.lib) optional optionals optionalString; };

stdenv.mkDerivation rec {
  name = basename + optionalString (cross != null) "-${cross.config}";

  src = fetchurl {
    url = "mirror://gnu/binutils/${basename}.tar.bz2";
    sha256 = "06bs5v5ndb4g5qx96d52lc818gkbskd1m0sz57314v887sqfbcia";
  };

  patches = [
    # Turn on --enable-new-dtags by default to make the linker set
    # RUNPATH instead of RPATH on binaries.  This is important because
    # RUNPATH can be overriden using LD_LIBRARY_PATH at runtime.
    (fetchTritonPatch {
      rev = "a998b3cf816a979c701495a9cb4379d5fae83eee";
      file = "binutils/new-dtags.patch";
      sha256 = "c2c3e8ce7ec166bfaea20db66d7358942757214bcc7c4b75f005f78ea5b2ba03";
    })

    # Since binutils 2.22, DT_NEEDED flags aren't copied for dynamic outputs.
    # That requires upstream changes for things to work. So we can patch it to
    # get the old behaviour by now.
    (fetchTritonPatch {
      rev = "a998b3cf816a979c701495a9cb4379d5fae83eee";
      file = "binutils/dtneeded.patch";
      sha256 = "16dca5a36a94de8f677450b6b83abd96a692be322b4a49e3d0cd2e2cdc3d11b7";
    })

    # Make binutils output deterministic by default.
    (fetchTritonPatch {
      rev = "a998b3cf816a979c701495a9cb4379d5fae83eee";
      file = "binutils/deterministic.patch";
      sha256 = "912815241d4f64f971b22deb456217b8288b44b2f96ae0e50289a911dbecddc8";
    })

    # Always add PaX flags section to ELF files.
    # This is needed, for instance, so that running "ldd" on a binary that is
    # PaX-marked to disable mprotect doesn't fail with permission denied.
    (fetchTritonPatch {
      rev = "a998b3cf816a979c701495a9cb4379d5fae83eee";
      file = "binutils/pt-pax-flags-20121023.patch";
      sha256 = "6f01fa85cbc2428ac40e2325bafcc01dcbd3dde6ec9f0dc7367b8474049021a2";
    })
  ];

  nativeBuildInputs = optional gold bison;
  buildInputs = [ zlib ];

  inherit noSysDirs;

  preConfigure = ''
    # Clear the default library search path.
    if test "$noSysDirs" = "1"; then
        echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt
    fi

    # Use symlinks instead of hard links to save space ("strip" in the
    # fixup phase strips each hard link separately).
    for i in binutils/Makefile.in gas/Makefile.in ld/Makefile.in gold/Makefile.in; do
        sed -i "$i" -e 's|ln |ln -s |'
    done
  '';

  configureFlags =
    [ "--enable-shared" "--enable-deterministic-archives" "--disable-werror" ]
    ++ optional (stdenv.system == "mips64el-linux") "--enable-fix-loongson2f-nop"
    ++ optional (cross != null) "--target=${cross.config}"
    ++ optionals gold [ "--enable-gold" "--enable-plugins" ]
    ++ optional (stdenv.system == "i686-linux") "--enable-targets=x86_64-linux-gnu";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    longDescription = ''
      The GNU Binutils are a collection of binary tools.  The main
      ones are `ld' (the GNU linker) and `as' (the GNU assembler).
      They also include the BFD (Binary File Descriptor) library,
      `gprof', `nm', `strip', etc.
    '';
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;

    /* Give binutils a lower priority than gcc-wrapper to prevent a
       collision due to the ld/as wrappers/symlinks in the latter. */
    priority = "10";
  };
}
