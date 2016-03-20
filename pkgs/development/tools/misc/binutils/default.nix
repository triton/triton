{ stdenv
, bison
, fetchTritonPatch
, fetchurl

, zlib
}:

let
  inherit (stdenv.lib)
    optional
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "binutils-2.23.1";

  src = fetchurl {
    url = "mirror://gnu/binutils/${name}.tar.bz2";
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

  nativeBuildInputs = [
    bison
  ];

  buildInputs = [
    zlib
  ];

  preConfigure = ''
    # Clear the default library search path.
    echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt

    # Use symlinks instead of hard links to save space ("strip" in the
    # fixup phase strips each hard link separately).
    for i in $(find . -name Makefile.in); do
        sed -i "$i" -e 's|ln |ln -s |'
    done
  '';

  configureFlags = [
    "--enable-shared"
    "--enable-deterministic-archives"
    "--disable-werror"
    "--enable-gold"
    "--enable-plugins"
  ];

  meta = with stdenv.lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
