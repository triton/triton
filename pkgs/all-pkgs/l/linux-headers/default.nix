{ stdenv
, fetchurl
, lib
}:

let
  source = {
    version = "5.5.13";
    baseSha256 = "a6fbd4ee903c128367892c2393ee0d9657b6ed3ea90016d4dc6f1f6da20b2330";
    patchSha256 = "a58dad931dda6eba7656551da73d1c452317617c8282c094fa4f646d9422993a";
  };

  sourceFetch = import ../linux/source.nix {
    inherit
      lib
      fetchurl
      source;
    fetchFromGitHub = null;
  };

  headerArch = {
    "x86_64-linux" = "x86_64";
    "i686-linux" = "i386";
  };

  arch = headerArch."${stdenv.targetSystem}";

  inherit (lib)
    optionals
    versionAtLeast;
in
stdenv.mkDerivation rec {
  name = "linux-headers-${source.version}";

  inherit (sourceFetch)
    src;

  patches = [
    sourceFetch.patch
  ];

  buildPhase = ''
    make -j160 ARCH=${arch} headers
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -r usr/include "$out"
  '';

  preFixup = ''
    # Cleanup some unneeded files
    find "$out" -type f -and -not -name '*.h' -delete -print
  '';

  # The linux-headers do not need to maintain any references
  allowedReferences = [ ];

  meta = with stdenv.lib; {
    description = "Header files and scripts for Linux kernel";
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      i686-linux
      ++ x86_64-linux;
  };
}
