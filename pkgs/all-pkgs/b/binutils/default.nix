{ stdenv
, fetchurl

, zlib

, type ? "full"
}:

let
  inherit (stdenv.lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString
    stringLength;

  target =
    if type == "bootstrap" then
      "x86_64-tritonboot-linux-gnu"
    else
      "x86_64-pc-linux-gnu";
in
stdenv.mkDerivation (rec {
  name = "binutils-2.31.1";

  src = fetchurl {
    url = "mirror://gnu/binutils/${name}.tar.xz";
    hashOutput = false;
    sha256 = "5d20086ecf5752cc7d9134246e9588fa201740d540f7eb84d795b1f7a93bca86";
  };

  buildInputs = optionals (type != "bootstrap") [
    zlib
  ];

  postPatch = ''
    # Don't rebuild the docs for bfd
    sed -i '/SUBDIRS/s, doc,,' bfd/Makefile.in

    # Fix host lib install directory
    find . -name configure -exec sed -i \
      's,^\([[:space:]]*bfd\(lib\|include\)dir=\).*$,\1"\\''${\2dir}",' {} \;
  '';

  preConfigure = ''
    # Clear the default library search path.
    grep -q 'NATIVE_LIB_DIRS=' ld/configure.tgt
    echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt
  '';

  configureFlags = [
    "--target=${target}"
    "--enable-shared"
    # Autodetection is not working for binutils because of how the nested
    # configure system works
    "--disable-static"
    "--${boolEn (type != "bootstrap")}-nls"
    "--disable-werror"
    "--enable-deterministic-archives"
    "--${boolEn (type != "bootstrap")}-gold"
    "--${boolWt (type != "bootstrap")}-system-zlib"
  ];

  preBuild = ''
    # Needed otherwise it defaults to $prefix/$archtriple
    makeFlagsArray+=("tooldir=$out")
  '';

  postInstall = ''
    # Ensure we have all of the non-prefixed tools
    for bin in "$out"/bin/${target}-*; do
      base="$(basename "$bin")"
      tool="$out/bin/''${base:${toString (stringLength (target + "-"))}}"
      rm -fv "$tool"
      ln -srv "$bin" "$tool"
    done

    # Invert ld links so that ld.bfd / ld.gold are the proper tools
    ld="$out"/bin/${target}-ld
    if [ ! -e "$ld" ]; then
      ld="$out"/bin/ld
    fi
    for bin in "$ld".*; do
      if [ -L "$bin" ]; then
        if [ "$(readlink -f "$bin")" = "$ld" ]; then
          rm -v "$bin"
          mv -v "$ld" "$bin"
          ln -srv "$bin" "$ld"
        fi
      else
        if cmp "$bin" "$ld"; then
          rm -v "$ld"
          ln -srv "$bin" "$ld"
        fi
      fi
    done
  '';

  preFixup = optionalString (type != "full") ''
    # Remove unused files from bootstrap
    rm -r "$out"/share
  '' + ''
    # Libtool files reference intermediate static libraries in the build
    # like libiberty. We don't need them anyway
    rm "$out"/lib/*.la

    # We don't build against binutils libraries so we don't need their headers
    rm -r "$out"/include
  '';

  meta = with stdenv.lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
} // optionalAttrs (type != "bootstrap") {
  # Ensure we don't depend on anything unexpected
  allowedReferences = [
    "out"
    stdenv.cc.libc
    stdenv.cc.libgcc
    zlib
  ];
})
