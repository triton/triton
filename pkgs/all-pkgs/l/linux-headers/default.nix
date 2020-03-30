{ stdenv
, fetchurl
, lib
}:

let
  source = {
    version = "5.6";
    baseSha256 = "e342b04a2aa63808ea0ef1baab28fc520bd031ef8cf93d9ee4a31d4058fcb622";
    patchSha256 = null;
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
