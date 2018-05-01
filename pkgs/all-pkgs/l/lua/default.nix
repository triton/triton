{ stdenv
, fetchTritonPatch
, fetchurl

, readline

, channel
}:

let
  sources = {
    "5.2" = {
      version = "5.2.4";
      multihash = "QmWJdzGBRfifvof4krhv3FRPFxD2FUmz6VcQ83emcoGTML";
      sha256 = "b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b";
    };
    "5.3" = {
      version = "5.3.4";
      multihash = "QmNYqRyfDBStum87ptEAZWBbjAXKC6pmZX9vuJzcdhK5Ru";
      sha256 = "f681aa518233bc407e23acf0f5887c884f17436f000d453b2491a9f11a52400c";
    };
  };
  source = sources."${channel}";
in
stdenv.mkDerivation rec {
  name = "lua-${source.version}";

  src = fetchurl {
    url = "https://www.lua.org/ftp/${name}.tar.gz";
    inherit (source)
      multihash
      sha256;
  };

  buildInputs = [
    readline
  ];

  patches = [
    (fetchTritonPatch {
      rev = "0619357d1bd2ab053c2fb3532d959660eaca6433";
      file = "l/lua/liblua.so.patch";
      sha256 = "2cc83c77423a2dda3696766b2d1ccee2796e052ab04d5178905f41ed9241a3d8";
    })
  ];

  postPatch = ''
    sed -i "/LUA_ROOT/ s,/usr,$out," src/luaconf.h
  '';

  preBuild = ''
    makeFlagsArray+=(
      "INSTALL_TOP=$out"
    )
  '';

  NIX_CFLAGS_COMPILE = [
    "-DLUA_COMPAT_5_1"
    "-DLUA_COMPAT_5_2"
  ];

  buildFlags = [
    "linux"
  ];

  preInstall = ''
    installFlagsArray+=(
      "TO_LIB=liblua.so liblua.so.${channel} liblua.so.${source.version}"
      "INSTALL_DATA=cp -d"
      "INSTALL_MAN=$out/share/man/man1"
    )
  '';

  postInstall = ''
    mkdir -p $out/lib/pkgconfig/
    cat > $out/lib/pkgconfig/lua.pc <<EOF
    prefix=$out
    INSTALL_BIN=\''${prefix}/bin
    INSTALL_INC=\''${prefix}/include
    INSTALL_LIB=\''${prefix}/lib
    INSTALL_MAN=\''${prefix}/man/man1
    INSTALL_LMOD=\''${prefix}/share/lua/${channel}
    INSTALL_CMOD=\''${prefix}/lib/lua/${channel}
    exec_prefix=\''${prefix}
    libdir=\''${exec_prefix}/lib
    includedir=\''${prefix}/include

    Name: Lua
    Description: An Extensible Extension Language
    Version: ${source.version}
    Libs: -L\''${libdir} -llua -lm
    Cflags: -I\''${includedir}

    EOF

    # Remove empty directory
    rm -rv $out/lib/lua/
  '';

  meta = with stdenv.lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
