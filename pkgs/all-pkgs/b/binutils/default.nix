{ stdenv
, cc
, fetchurl
, fetchTritonPatch
, hostcc
, patchelf
, lib

, zlib

, target ? null
, type ? "full"
}:

let
  inherit (lib)
    boolEn
    boolWt
    optional
    optionals
    optionalAttrs
    optionalString
    stringLength;

  supportGold = type != "bootstrap";
  defaultGold = supportGold && (
    if target == null then
      [ stdenv.targetSystem ] != lib.platforms.powerpc64le-linux
    else
      !(lib.hasPrefix "powerpc" target)
    );
in
stdenv.mkDerivation rec {
  name = "binutils-2.34";

  src = fetchurl {
    url = "mirror://gnu/binutils/${name}.tar.xz";
    hashOutput = false;
    sha256 = "f00b0e8803dc9bab1e2165bd568528135be734df3fabf8d0161828cd56028952";
  };

  nativeBuildInputs = [
    cc
    hostcc
    patchelf
  ];

  buildInputs = optionals (type != "bootstrap") [
    zlib
  ];

  patches = [
    (fetchTritonPatch {
      rev = "b42aadf32b9163a2c7dcd30f68210a2797bbda8f";
      file = "b/binutils/0001-bfd-No-bundled-bfd-plugin-support.patch";
      sha256 = "2611d9d326c615e2d3cfa71640b35ecd40338b7bd32cd92f26f35557b75142d5";
    })
  ] ++ optionals (type != "bootstrap") [
    (fetchTritonPatch {
      rev = "780a4108d3b9ffeab7c54dd68f7c7967d4e83b78";
      file = "b/binutils/0001-gold-Don-t-use-absolute-file-paths-for-version-table.patch";
      sha256 = "64750440ba41b3e7370a4535db230d43f39b583e12d566c6b28c6a3ef556d739";
    })
    (fetchTritonPatch {
      rev = "9e454c8e63e519768d1dd557af5572eaed941e2b";
      file = "b/binutils/0001-gold-Make-consistent-with-bfd-script-search-behavior.patch";
      sha256 = "77857fc87f4a719e848116085ddfc5f54b8cced34d15953e1c644bd277a1ecc4";
    })
  ];

  postPatch = ''
    # Don't rebuild the docs for bfd
    find . -name Makefile.in -exec sed -i '/SUBDIRS/s, doc,,' {} \;

    # Fix host lib install directory
    find . -name configure -exec sed -i \
      's,^\([[:space:]]*bfd\(lib\|include\)dir=\).*$,\1"\\''${\2dir}",' {} \;
  '';

  preConfigure = ''
    # Clear the default library search path.
    grep -q 'NATIVE_LIB_DIRS=' ld/configure.tgt
    echo 'NATIVE_LIB_DIRS=' >> ld/configure.tgt

    # Needed by cross linker to search DT_RUNPATH of libs during link
    # Otherwise, we won't have the necessary search paths for transitive libs
    export USE_LIBPATH='yes'
  '';

  configureFlags = [
    "--exec-prefix=${placeholder "bin"}"
    "--datarootdir=${placeholder "bin"}/share"
    (optionalString (target != null) "--target=${target}")
    "--${boolEn (type == "full")}-nls"
    "--disable-werror"
    "--enable-deterministic-archives"
    "--${boolEn supportGold}-gold${optionalString defaultGold "=default"}"
    "--${boolWt (type != "bootstrap")}-system-zlib"
    "--with-separate-debug-dir=/no-such-path/debug"
  ];

  postInstall = ''
    # Invert ld links so that ld.bfd / ld.gold are the proper tools
    ld="$(echo "$bin"/*/bin/ld)"
    if [ -z "$ld" ]; then
      ld="$bin"/bin/ld
    fi
    for prog in "$ld".*; do
      if [ -L "$prog" ]; then
        if [ "$(readlink -f "$prog")" = "$ld" ]; then
          rm -v "$prog"
          mv -v "$ld" "$prog"
          ln -srv "$prog" "$ld"
        fi
      else
        if cmp "$prog" "$ld"; then
          rm -v "$ld"
          ln -srv "$prog" "$ld"
        fi
      fi
    done

    # Make all duplicate binaries symlinks
    declare -A progMap
    for prog in "$bin"/*/bin/* "$bin"/bin/*; do
      if [ -L "$prog" ]; then
        continue
      fi
      checksum="$(cksum "$prog" | cut -d ' ' -f1)"
      oProg="''${progMap["$checksum"]-}"
      if [ -z "$oProg" ]; then
        progMap["$checksum"]="$prog"
      elif cmp "$prog" "$oProg"; then
        rm -v "$prog"
        ln -srv "$oProg" "$prog"
      fi
    done

    # Move outputs to their final locations
    mkdir -p "$lib"/lib
    mv "$bin"/lib*/*.so* "$lib"/lib
    ln -sv "$lib"/lib/* "$bin"/lib
    mv "$bin"/lib "$dev"
  '';

  preFixup = ''
    # Missing install of private static libraries
    rm -v "$dev"/lib/*.la
  '';

  postFixup = ''
    mkdir -p "$bin"/share2
  '' + optionalString (type == "full") ''
    mv "$bin"/share/locale "$bin"/share2
  '' + ''
    rm -rv "$bin"/share
    mv "$bin"/share2 "$bin"/share
  '';

  outputs = [
    "dev"
    "bin"
    "lib"
  ] ++ optionals (type == "full") [
    "man"
  ];

  passthru = {
    inherit target;
  };

  meta = with lib; {
    description = "Tools for manipulating binaries (linker, assembler, etc.)";
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux ++
      x86_64-linux ++
      powerpc64le-linux;
  };
}
