{ stdenv
, fetchurl
}:

let
  version = "2.0.4";
in
stdenv.mkDerivation rec {
  name  = "luajit-${version}";

  src = fetchurl {
    url = "http://luajit.org/download/LuaJIT-${version}.tar.gz";
    sha256 = "0zc0y7p6nx1c0pp4nhgbdgjljpfxsb5kgwp4ysz22l1p2bms83v2";
  };

  preBuild = ''
    makeFlagsArray+=(
      "amalg"
      "PREFIX=$out"
    )
  '';

  # Provide backward compatible paths
  postInstall = ''
    pushd "$out/include"
    dir="$(ls)"
    ln -sv "$dir" luajit
    ln -sv "$dir" lua
    popd

    pushd "$out/lib"
    so="$(find . -type f -name \*.so\*)"
    ln -sv "$so" libluajit.so
    ln -sv "$so" liblua.so

    a="$(find . -type f -name \*.a\*)"
    ln -sv "$a" libluajit.a
    ln -sv "$a" liblua.a
    popd
  '';

  meta = with stdenv.lib; {
    description = "high-performance JIT compiler for Lua 5.1";
    homepage = http://luajit.org;
    license = licenses.mit;
    maintainers = with maintainers; [
      wkennington
    ];
    platforms = with platforms;
      x86_64-linux;
  };
}
