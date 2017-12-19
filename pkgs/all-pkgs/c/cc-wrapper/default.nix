{ stdenv
, cc
, fetchurl
, gnumake
, lib
}:

let
  hostCc = cc;
in

{ cc
, libc
, wrappedPackages ? [ ]
}:

let
  inherit (lib)
    head;
  inherit (lib.platforms)
    i686-linux
    x86_64-linux;
in
stdenv.mkDerivation {
  name = "cc-wrapper";

  nativeBuildInputs = [
    gnumake
  ];

  buildInputs = [
    cc
  ] ++ wrappedPackages;

  passthru = {
    platformTuples = {
      "${head x86_64-linux}" = "x86_64-pc-linux-gnu";
      "${head x86_64-linux}-boot" = "x86_64-nixboot-linux-gnu";
      "${head i686-linux}" = "i686-pc-linux-gnu";
      "${head i686-linux}-boot" = "i686-nixboot-linux-gnu";
    };
  };

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
  };
}
