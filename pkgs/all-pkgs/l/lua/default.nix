{ stdenv
, fetchTritonPatch
, fetchurl
, lib

, readline

, channel
}:

let
  inherit (lib)
    optionalString
    replaceStrings
    versionAtLeast;

  sources = {
    "5.2" = {
      version = "5.2.4";
      multihash = "QmWJdzGBRfifvof4krhv3FRPFxD2FUmz6VcQ83emcoGTML";
      sha256 = "b9e2e4aad6789b3b63a056d442f7b39f0ecfca3ae0f1fc0ae4e9614401b69f4b";
    };
    "5.3" = {
      version = "5.3.5";
      multihash = "QmezDfvLkh3Yso3DxVQTHpvkGhXXLrnAkjA4WHQPbE79CW";
      sha256 = "0c2eed3f960446e1a3e4b9a1ca2f3ff893b6ce41942cf54d5dd59ab4b3b058ac";
    };
  };
  source = sources."${channel}";

  channel' = replaceStrings ["."] [""] channel;
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

  postPatch = optionalString (versionAtLeast source.version "5.3.4") ''
    grep -q '$V\.4' Makefile
    sed -i "s,\$V\.4,${source.version}," Makefile
  '' + ''
    grep -q '/usr' src/luaconf.h
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
    mkdir -p "$out"/lib/pkgconfig
    sed '${./lua.pc.in}' \
      -e 's,@version@,${source.version},' \
      -e 's,@channel@,${channel},' \
      -e "s,@prefix@,$out," \
      >"$out"/lib/pkgconfig/lua${channel'}.pc
    ln -sv lua${channel'}.pc "$out"/lib/pkgconfig/lua.pc

    # Remove empty directory
    rm -rv "$out"/lib/lua/
  '';

  meta = with lib; {
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
