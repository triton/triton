{ stdenv
, fetchurl
, gnum4

, bzip2
, xz
, zlib
}:

let
  inherit (import ./common.nix { inherit fetchurl; })
    version
    src
    srcVerification;
in
stdenv.mkDerivation rec {
  name = "elfutils-${version}";

  inherit src;

  nativeBuildInputs = [
    gnum4
  ];

  buildInputs = [
    bzip2
    xz
    zlib
  ];

  configureFlags = [
    "--disable-maintainer-mode"
    "--enable-deterministic-archives"
  ];

  passthru = {
    inherit
      version
      srcVerification;
  };

  meta = with stdenv.lib; {
    description = "Libraries/utilities to handle ELF objects";
    homepage = https://sourceware.org/elfutils/;
    license = licenses.gpl2;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
