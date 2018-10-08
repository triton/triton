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
    # Make binutils output deterministic by default.
    (fetchTritonPatch {
      rev = "a998b3cf816a979c701495a9cb4379d5fae83eee";
      file = "binutils/deterministic.patch";
      sha256 = "912815241d4f64f971b22deb456217b8288b44b2f96ae0e50289a911dbecddc8";
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
