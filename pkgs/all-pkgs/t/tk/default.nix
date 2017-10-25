{ stdenv
, fetchurl
, lib

, tcl_8-5
, tcl_8-6
, libx11
, xorg
, xproto
, zlib

, channel
}:

let
  sources = {
    "8.5" = {
      sha256 = "407af1de167477d598bd6166d84459a3bdccc2fb349360706154e646a9620ffa";
    };
    "8.6" = {
      sha256 = "c65d6c00a7c8826069979b9d57332227e0b69d741b48093a13ac9ed6bea74304";
    };
  };
  source = sources."${channel}";

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
    inherit (source) sha256;
  };

  buildInputs = [
    tcl
    libx11
    xorg.libXft
    xproto
    zlib
  ];

  /*patches = optionals isTk86 [
    ./different-prefix-with-tcl.patch
  ];*/

  postUnpack = ''
    srcRoot="$sourceRoot/unix"
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

  meta = with lib; {
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
