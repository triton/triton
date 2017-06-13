{ stdenv
, fetchurl
}:

let
  version = "2.0.5";
in
stdenv.mkDerivation rec {
  name  = "luajit-${version}";

  src = fetchurl {
    url = "https://luajit.org/download/LuaJIT-${version}.tar.gz";
    multihash = "QmPAYcifDQ5QbKjrhCM35gXznxMkHiLVZwM3zVZgbJNCvZ";
    sha256 = "874b1f8297c697821f561f9b73b57ffd419ed8f4278c82e05b48806d30c1e979";
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
