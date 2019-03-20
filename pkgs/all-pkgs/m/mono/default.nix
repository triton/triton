{ stdenv
, bison
, cmake
, fetchurl
, gettext
, lib

, boehm-gc
, glib
, perl
, python
, libgdiplus
, libx11
, ncurses
, zlib

, channel ? "5.4"
}:

let
  inherit (lib)
    boolEn
    boolWt
    optional
    optionals
    optionalString;

  sources = {
    "5.4" = {
      version = "5.4.0.201";
      sha256 = "2a2f5c2a214a9980c086ac7561a5dd106f13d823a630de218eabafe1d995c5b4";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "mono-${source.version}";

  src = fetchurl {
    url = "https://download.mono-project.com/sources/mono/${name}.tar.bz2";
    inherit (source) sha256;
  };

  nativeBuildInputs = [
    bison
    cmake
    gettext
    perl
    python
  ];

  buildInputs = [
    boehm-gc
    glib
    libgdiplus
    libx11
    ncurses
    zlib
  ];

  postPatch = ''
    patchShebangs .
  '' + /* Fix pkgconfig files (not seting variables during build) */ ''
    for file in data/*; do
      if [ -f "$file" ]; then
        sed -i $file \
          -e "s,\''${prefix},$out," \
          -e "s,\''${assemblies_dir},$out/lib/mono," \
          -e "s,\''${libdir},$out/lib,"
      fi
    done
  '';

  configureFlags = [
    "--enable-nls"
    "--disable-werror"
    "--enable-libraries"
    "--enable-mcs-build"
    "--disable-small-config"
    "--enable-system-aot"
    "--enable-executables"
    "--disable-gsharedvt"
    "--${boolEn (boehm-gc != null)}-boehm"
    "--${boolEn (boehm-gc != null)}-parallel-mark"
    "--enable-dev-random"
    "--enable-bcl-opt"
    "--enable-big-arrays"  # Arrays greater than Int32.MaxValue
    "--disable-dtrace"
    "--disable-llvm"
    "--disable-loadedllvm"
    "--disable-llvm-version-check"
    "--disable-llvm-runtime"
    #"--enable-vtune"
    "--enable-interpreter"
    #"--enable-icall-symbol-map"
    #"--enable-icall-export"
    #"--disable-icall-tables"
    "--enable-blts"
    "--with-crosspkgdir=$(out)/lib/pkgconfig"
    "--with-tls=pthread"
    # FIXME: https://bugzilla.xamarin.com/show_bug.cgi?id=33081
    #"--without-static_mono"
    #"--with-shared_mono"
    "--with-large-heap"
    #"--without-llvm"  # Option is not a boolean
    "--with-x"
    #"--with-libgdiplus=${libgdiplus}/lib/libgdiplus.so"
  ];

  NIX_LDFLAGS = "-lgcc_s";

  makeFlags = [
    "INSTALL=install"
  ];

  # Fix mono DLLMap so it can find libX11 and gdiplus to run winforms apps
  # Other items in the DLLMap may need to be pointed to their store locations
  # http://www.mono-project.com/Config_DllMap
  postBuild = ''
    find . -name 'config' -type f | while read i; do
      sed -i "s@libX11.so.6@${libx11}/lib/libX11.so.6@g" $i
      #sed -i "s@/.*libgdiplus.so@${glib}/lib/libgdiplus.so@g" $i
    done
  '';

  cmakeHook = false;
  disableStatic = false; # https://bugzilla.novell.com/show_bug.cgi?id=644723
  dontStrip = true;
  buildDirCheck = false;
  ninjaHook = false;

  meta = with lib; {
    description = "Mono runtime and class libraries, a C# compiler/interpreter";
    homepage = http://mono-project.com/;
    license = licenses.gpl1;  # Combination of LGPL1/X11/GPL1/MPL
    maintainers = with maintainers; [
      codyopel
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
