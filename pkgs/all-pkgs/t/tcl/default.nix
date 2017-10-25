{ stdenv
, fetchurl
, lib

, zlib

, channel
}:

let
  sources = {
    "8.5" = {
      version = "8.5.19";
      sha256 = "d3f04456da873d17f02efc30734b0300fb6c3b85028d445fe284b83253a6db18";
    };
    "8.6" = {
      version = "8.6.7";
      sha256 = "7c6b8f84e37332423cfe5bae503440d88450da8cc1243496249faa5268026ba5";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "tcl-${source.version}";

  src = fetchurl {
    url = "mirror://sourceforge/tcl/Tcl/${source.version}/"
      + "tcl${source.version}-src.tar.gz";
    inherit (source) sha256;
  };

  buildInputs = [
    zlib
  ];

  postUnpack = ''
    srcRoot="$sourceRoot/unix"
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

  buildDirCheck = false;  # FIXME

  passthru = rec {
    inherit channel;
    inherit (source) version;
    libPrefix = "tcl${channel}";
    libdir = "lib/${libPrefix}";
  };

  meta = with lib; {
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
