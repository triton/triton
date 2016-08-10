{ stdenv
, fetchurl

, tcl_8-5
, tcl_8-6
, xorg
, zlib

, channel ? null
}:

let
  inherit (stdenv.lib)
    any
    optionals
    versionAtLeast
    versionOlder;
  inherit (builtins.getAttr channel (import ./sources.nix))
    sha256;
in

assert any (n: n == channel) [
  "8.5"
  "8.6"
];

let
  isTk85 =
    if channel == "8.5" then
      true
    else
      false;
  isTk86 =
    if channel == "8.6" then
      true
    else
      false;

  tcl =
    if isTk85 then
      tcl_8-5
    else if isTk86 then
      tcl_8-6
    else
      null;

  version = tcl.version;
in

stdenv.mkDerivation rec {
  name = "tk-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/tcl/tk${version}-src.tar.gz";
    inherit sha256;
  };

  buildInputs = [
    tcl
    xorg.libX11
    xorg.libXft
    xorg.xproto
    zlib
  ];

  /*patches = optionals isTk86 [
    ./different-prefix-with-tcl.patch
  ];*/

  postUnpack = ''
    sourceRoot="$sourceRoot/unix"
  '';

  postInstall = ''
    ln -sv $out/bin/wish${channel} $out/bin/wish
  '';

  configureFlags = [
    "--with-tcl=${tcl}/lib"
  ];

  passthru = rec {
    inherit
      channel
      isTk85
      isTk86
      version;
    libPrefix = "tk${channel}";
    libdir = "lib/${libPrefix}";
  };

  meta = with stdenv.lib; {
    description = "A widget toolkit";
    homepage = http://www.tcl.tk/;
    license = licenses.tcltk;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
