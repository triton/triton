{ stdenv, fetchurl, readline, compat ? false }:

stdenv.mkDerivation rec {
  name = "lua-${version}";
  luaversion = "5.3";
  version = "${luaversion}.2";

  src = fetchurl {
    url = "http://www.lua.org/ftp/${name}.tar.gz";
    sha1 = "7a47adef554fdca7d0c5536148de34579134a973";
  };

  nativeBuildInputs = [ readline ];

  configurePhase = ''
    makeFlagsArray=( INSTALL_TOP=$out INSTALL_MAN=$out/share/man/man1 PLAT=linux CFLAGS="-DLUA_USE_LINUX -O2 -fPIC${if compat then " -DLUA_COMPAT_ALL" else ""}" LDFLAGS="-fPIC" V=${luaversion} R=${version})
    installFlagsArray=( TO_BIN="lua luac" TO_LIB="liblua.a liblua.so liblua.so.${luaversion} liblua.so.${version}" INSTALL_DATA='cp -d' )
    cat ${./lua-5.3-dso.make} >> src/Makefile
    sed -e 's/ALL_T *= */& $(LUA_SO)/' -i src/Makefile
  '';

  postBuild = stdenv.lib.optionalString true ''
    ( cd src; make liblua.so "''${makeFlagsArray[@]}" )
  '';

  postInstall = ''
    mkdir -p "$out/share/doc/lua" "$out/lib/pkgconfig"
    mv "doc/"*.{gif,png,css,html} "$out/share/doc/lua/"
    rmdir $out/{share,lib}/lua/${luaversion} $out/{share,lib}/lua
    mkdir -p "$out/lib/pkgconfig"
    cat >"$out/lib/pkgconfig/lua.pc" <<EOF
    prefix=$out
    libdir=$out/lib
    includedir=$out/include
    INSTALL_BIN=$out/bin
    INSTALL_INC=$out/include
    INSTALL_LIB=$out/lib
    INSTALL_MAN=$out/man/man1

    Name: Lua
    Description: An Extensible Extension Language
    Version: ${version}
    Requires:
    Libs: -L$out/lib -llua -lm
    Cflags: -I$out/include
    EOF
  '';

  crossAttrs = let
    isMingw = stdenv.cross.libc == "msvcrt";
    isDarwin = stdenv.cross.libc == "libSystem";
  in {
    configurePhase = ''
      makeFlagsArray=(
        INSTALL_TOP=$out
        INSTALL_MAN=$out/share/man/man1
        CC=${stdenv.cross.config}-gcc
        STRIP=:
        RANLIB=${stdenv.cross.config}-ranlib
        V=${luaversion}
        R=${version}
      )
    '' + stdenv.lib.optionalString isMingw ''
      installFlagsArray=(
        TO_BIN="lua.exe luac.exe"
        TO_LIB="liblua.a lua52.dll"
        INSTALL_DATA="cp -d"
      )
    '';
  };

  meta = {
    homepage = "http://www.lua.org";
    description = "Powerful, fast, lightweight, embeddable scripting language";
    license = stdenv.lib.licenses.mit;
    hydraPlatforms = stdenv.lib.platforms.linux;
    maintainers = [ stdenv.lib.maintainers.simons ];
  };
}
