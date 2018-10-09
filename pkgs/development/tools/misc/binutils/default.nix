{ stdenv
, bison
, fetchTritonPatch
, fetchurl
, texinfo

, zlib
}:

let
  inherit (stdenv.lib)
    optional
    optionals
    optionalString;
in
stdenv.mkDerivation rec {
  name = "binutils-2.31.1";

  src = fetchurl {
    url = "mirror://gnu/binutils/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5d20086ecf5752cc7d9134246e9588fa201740d540f7eb84d795b1f7a93bca86";
  };

  nativeBuildInputs = [
    bison
    texinfo
  ];

  buildInputs = [
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "ee7246d6cd30ae3d8ba0f9531684f2cb0c40abeb";
      file = "b/binutils/0000-2.31.1-2018-10-09.patch";
      sha256 = "6246b9a14eebca5aeac7cc35f7aaa4351b5d1e3d5aca84d8b4b75bcf5b0359a0";
    })
  ];

  preConfigure = ''
    # Clear the default library search path.
    grep -q 'NATIVE_LIB_DIRS=' ld/configure.tgt
    echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt

    # Symlink all tools instead of hardlinking to make sure
    # we save space when packing the derivation
    find . -name Makefile.in -exec sed -i 's,ln \$,ln -s $,' {} \;
  '';

  configureFlags = [
    "--enable-shared"
    # Autodetection is not working for binutils because of how the nested
    # configure system works
    "--disable-static"
    "--enable-deterministic-archives"
    "--enable-gold"
    "--enable-plugins"
    "--with-system-zlib"
  ];

  preBuild = ''
    # Needed otherwise it defaults to $prefix/$archtriple
    makeFlagsArray+=("tooldir=$out")
  '';

  # Libtool files reference intermediate static libraries in the build
  # like libiberty. We don't need them anyway
  postInstall = ''
    rm "$out"/lib/*.la
  '';

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
