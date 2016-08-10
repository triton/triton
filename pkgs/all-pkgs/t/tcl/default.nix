{ stdenv
, fetchurl

, zlib

, channel ? null
}:

let
  inherit (stdenv.lib)
    any
    versionAtLeast
    versionOlder;
  inherit (builtins.getAttr channel (import ./sources.nix))
    multihash
    sha256
    version;
in

assert any (n: n == channel) [
  "8.5"
  "8.6"
];

let
  isTcl85 =
    if versionAtLeast version "8.5.0" && versionOlder version "8.6.0" then
      true
    else
      false;
  isTcl86 =
    if versionAtLeast version "8.6.0" && versionOlder version "8.7.0" then
      true
    else
      false;
in

stdenv.mkDerivation rec {
  name = "tcl-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/tcl/tcl${version}-src.tar.gz";
    inherit multihash sha256;
  };

  buildInputs = [
    zlib
  ];

  postUnpack = ''
    sourceRoot="$sourceRoot/unix"
  '';

  postPatch = ''
    sed -i Makefile.in \
      -e '/chmod/s:555:755:g'
  '';

  installTargets = [
    "install"
    "install-private-headers"
  ];

  postInstall = ''
    ln -sv $out/bin/tclsh${channel} $out/bin/tclsh
  '';

  passthru = rec {
    inherit
      channel
      isTcl85
      isTcl86
      version;
    libPrefix = "tcl${channel}";
    libdir = "lib/${libPrefix}";
  };
  
  meta = with stdenv.lib; {
    description = "The Tcl scription language";
    homepage = http://www.tcl.tk/;
    license = licenses.tcltk;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
